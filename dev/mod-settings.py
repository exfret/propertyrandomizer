#!/usr/bin/env python3
# Reads and writes Factorio mod-settings.dat files (property tree format)
#
# Usage:
#   dev/mod-settings.py show FILE [PREFIX]            print startup settings (optionally only names starting with PREFIX)
#   dev/mod-settings.py set IN OUT NAME=VALUE...      copy IN to OUT with the given startup settings changed
#
# VALUE is parsed as an int, float, true/false, or else a string; the setting must already exist in IN

import struct
import sys

# Property tree types
NONE, BOOL, NUMBER, STRING, LIST, DICT, SIGNED, UNSIGNED = range(8)


class Reader:
    def __init__(self, data):
        self.data = data
        self.pos = 0

    def take(self, fmt):
        values = struct.unpack_from("<" + fmt, self.data, self.pos)
        self.pos += struct.calcsize("<" + fmt)
        return values[0]

    def string(self):
        if self.take("B"):
            return ""
        length = self.take("B")
        if length == 255:
            length = self.take("I")
        text = self.data[self.pos:self.pos + length].decode("utf-8")
        self.pos += length
        return text

    def tree(self):
        kind = self.take("B")
        self.take("B")  # any-type flag
        if kind == NONE:
            return (kind, None)
        if kind == BOOL:
            return (kind, bool(self.take("B")))
        if kind == NUMBER:
            return (kind, self.take("d"))
        if kind == STRING:
            return (kind, self.string())
        if kind == SIGNED:
            return (kind, self.take("q"))
        if kind == UNSIGNED:
            return (kind, self.take("Q"))
        if kind in (LIST, DICT):
            count = self.take("I")
            items = []
            for _ in range(count):
                items.append((self.string(), self.tree()))
            return (kind, items)
        raise ValueError("Unknown property tree type " + str(kind) + " at byte " + str(self.pos - 2))


def write_string(out, text):
    encoded = text.encode("utf-8")
    out += struct.pack("<B", 0)
    if len(encoded) < 255:
        out += struct.pack("<B", len(encoded))
    else:
        out += struct.pack("<BI", 255, len(encoded))
    out += encoded


def write_tree(out, node):
    kind, value = node
    out += struct.pack("<BB", kind, 0)
    if kind == BOOL:
        out += struct.pack("<B", value)
    elif kind == NUMBER:
        out += struct.pack("<d", value)
    elif kind == STRING:
        write_string(out, value)
    elif kind == SIGNED:
        out += struct.pack("<q", value)
    elif kind == UNSIGNED:
        out += struct.pack("<Q", value)
    elif kind in (LIST, DICT):
        out += struct.pack("<I", len(value))
        for key, child in value:
            write_string(out, key)
            write_tree(out, child)


def load(path):
    with open(path, "rb") as f:
        data = f.read()
    reader = Reader(data)
    # Version (4 x u16) and a reserved byte
    header = data[:9]
    reader.pos = 9
    tree = reader.tree()
    if reader.pos != len(data):
        raise ValueError("Trailing bytes in " + path)
    return header, tree


def save(path, header, tree):
    out = bytearray(header)
    write_tree(out, tree)
    with open(path, "wb") as f:
        f.write(out)


def startup_settings(tree):
    for key, child in tree[1]:
        if key == "startup":
            return child[1]
    raise ValueError("No startup settings")


def setting_value(setting):
    for key, child in setting[1]:
        if key == "value":
            return child
    raise ValueError("Setting has no value")


def parse_value(text, kind):
    if kind == BOOL:
        if text not in ("true", "false"):
            raise ValueError("Expected true/false, got " + text)
        return text == "true"
    if kind in (SIGNED, UNSIGNED):
        return int(text)
    if kind == NUMBER:
        return float(text)
    return text


def main(argv):
    if len(argv) >= 2 and argv[0] == "show":
        _, tree = load(argv[1])
        prefix = argv[2] if len(argv) >= 3 else ""
        for name, setting in startup_settings(tree):
            if name.startswith(prefix):
                print(name + " = " + repr(setting_value(setting)[1]))
        return 0
    if len(argv) >= 3 and argv[0] == "set":
        header, tree = load(argv[1])
        settings = dict(startup_settings(tree))
        for assignment in argv[3:]:
            name, text = assignment.split("=", 1)
            if name not in settings:
                print("Unknown startup setting " + name, file=sys.stderr)
                return 1
            value_node = setting_value(settings[name])
            new_node = (value_node[0], parse_value(text, value_node[0]))
            for i, (key, child) in enumerate(settings[name][1]):
                if key == "value":
                    settings[name][1][i] = (key, new_node)
        save(argv[2], header, tree)
        return 0
    print(__doc__ or "See the usage comment at the top of this file", file=sys.stderr)
    return 1


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
