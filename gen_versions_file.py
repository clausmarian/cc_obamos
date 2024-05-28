import sys
from os import listdir, getcwd
from os.path import isdir, join
from json import dumps


SCRIPT_NAME = sys.argv[0]
GIT_RAW_URL = "https://raw.githubusercontent.com/clausmarian/cc_obamos/main/"


def skip(filename):
    return not (filename.startswith(".") or filename == SCRIPT_NAME)


def get_files(root):
    res = list()

    for file in list(filter(skip, listdir(root))):
        path = join(root, file)
        if isdir(path):
            res += get_files(path)
        else:
            res.append(path)

    return res


def get_raw_url(path):
    return join(GIT_RAW_URL, path)


def make_file_object(path):
    return {"path": path, "url": get_raw_url(path)}


def main(version):
    cwd = getcwd()
    files = list(
        map(lambda path: make_file_object(path[len(cwd) + 1 :]), get_files(cwd))
    )
    json = dumps({"version": version, "files": files}, indent=4)
    print(json)
    with open('versions.json', 'w') as file:
        file.write(json)


if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Version not provided!", file=sys.stderr)
    else:
        main(sys.argv[1])
