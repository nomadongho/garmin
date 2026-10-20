#!/usr/bin/env python3
"""SDK-free project checks, NOT a Monkey C compiler or simulator."""
from pathlib import Path
import re
import sys
import xml.etree.ElementTree as ET

ROOT = Path(__file__).resolve().parents[1]
NS = {"iq": "http://www.garmin.com/xml/connectiq"}


def main() -> int:
    manifest = ET.parse(ROOT / "manifest.xml")
    app = manifest.find("./iq:application", NS)
    assert app is not None, "Missing application"
    assert app.get("type") == "watchface", "Expected watchface app"
    assert app.get("minApiLevel") == "3.4.0", "Target must be CIQ 3.4.0"
    assert re.fullmatch(r"[0-9a-fA-F]{32}", app.get("id", "")), "Invalid app id"
    assert app.get("entry") == "StarterFaceApp", "Incorrect entry point"

    products = [p.get("id") for p in app.findall("./iq:products/iq:product", NS)]
    assert products == ["fr55"], f"Unexpected device targets: {products}"

    strings = ET.parse(ROOT / "resources/strings/strings.xml")
    assert strings.find(".//string[@id='AppName']") is not None, "Missing AppName"
    assert app.get("name") == "@Strings.AppName", "Bad app resource"

    jungle = (ROOT / "monkey.jungle").read_text()
    for expected in ("project.manifest = manifest.xml",
                     "base.sourcePath = source",
                     "base.resourcePath = resources"):
        assert expected in jungle, f"Missing jungle setting: {expected}"

    app_source = (ROOT / "source/StarterFaceApp.mc").read_text()
    face_source = (ROOT / "source/StarterFaceView.mc").read_text()
    assert "class StarterFaceApp extends App.AppBase" in app_source
    assert "return [new StarterFaceView()]" in app_source
    assert "class StarterFaceView extends WatchUi.WatchFace" in face_source
    assert "function onUpdate(dc)" in face_source
    print("Project XML, target device, source and build configuration: OK")
    print("Note: Monkey C compilation and device tests were NOT run.")
    return 0


if __name__ == "__main__":
    try:
        sys.exit(main())
    except (AssertionError, ET.ParseError, OSError) as exc:
        print(f"Static validation failed: {exc}", file=sys.stderr)
        sys.exit(1)
