import re
import sys

POETRY_FILE = 'pyproject.toml'
VERSION_PLACEHOLDER = '__bumped_version_placeholder__'
POETRY_VERSION_REGEX = r'\nversion = "(\d+\.\d+\.*\d*)"'
POETRY_VERSION_FIXED_PART_REGEX = r'(\nversion = ")\d+\.\d+\.*\d*(")'


def bump_version(file: str, version_regex: str, version_fixed_part_regex: str, part: str):
    with open(file, 'r') as f:
        file_content = f.read()

    version = re.findall(pattern=version_regex, string=file_content, flags=re.MULTILINE)[0]
    major, minor, patch = version.split(".")
    if part == "minor":
        minor = str(int(minor) + 1)
        patch = 0
    elif part == "major":
        major = str(int(major) + 1)
        minor = 0
        patch = 0
    elif part == "patch":
        patch = str(int(patch) + 1)
    else:
        raise IOError(f"Unknown version part: {part}")

    bumped_version = f'{major}.{minor}.{patch}'

    file_content_with_version_placeholder = re.sub(
        pattern=version_fixed_part_regex,
        string=file_content,
        repl=f'\\1{VERSION_PLACEHOLDER}\\2',
        flags=re.MULTILINE
    )
    file_content_with_bumped_version = file_content_with_version_placeholder.replace(VERSION_PLACEHOLDER, bumped_version)

    with open(file, 'w') as f:
        f.write(file_content_with_bumped_version)

    return bumped_version


if __name__ == '__main__':
    version_part = sys.argv[1]

    bump_version(
        file=POETRY_FILE,
        version_regex=POETRY_VERSION_REGEX,
        version_fixed_part_regex=POETRY_VERSION_FIXED_PART_REGEX,
        part=version_part
    )
