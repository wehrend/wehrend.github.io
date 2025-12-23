#!/usr/bin/python3
import re
import os
from glob import glob

# 1. Define the file patterns to search (TARGETING ONLY 07_memory)
FILE_PATTERNS = [
    'content/*/pages/07_memory/index_en.adoc',
    'pages/07_memory/index_en.adoc',
]

# Regex to find any section heading: finds 1 or more '=' followed by a space and captures the title.
SECTION_PATTERN = re.compile(r'^(\=+)\s+(.*)$')

# Regex to detect lines that are NOT section headings, NOT blank, and NOT Hugo front matter delimiters (--- or +++).
POTENTIAL_HEADER_CONTENT_PATTERN = re.compile(r'^(?!-{3,}|^\+{3,})\s*[^=].*$')


def fix_06_memory_sequence_aggressive(filepath):
    """
    Forces the very first section heading in the file to be '==' (Level 1)
    and removes non-front matter clutter that might be preceding it.
    """
    print(f"Aggressively fixing: {filepath}")
    modified_lines = []

    try:
        with open(filepath, 'r', encoding='utf-8') as f:
            lines = f.readlines()
    except Exception as e:
        print(f"  -> Error reading {filepath}: {e}")
        return

    # Flags to track state
    in_front_matter = False
    first_heading_found = False
    changes_made = False

    for line in lines:
        line_stripped = line.strip()
        is_front_matter_delimiter = line_stripped.startswith('---') or line_stripped.startswith('+++')

        # 1. Front Matter Tracking (to ignore content inside the YAML/TOML/JSON block)
        if is_front_matter_delimiter:
            in_front_matter = not in_front_matter
            modified_lines.append(line)
            continue

        if in_front_matter:
            modified_lines.append(line)
            continue

        # 2. Section Heading Fix
        match_section = SECTION_PATTERN.match(line)
        if match_section:
            if not first_heading_found:
                # Force the first heading to be Level 1 (==)
                title = match_section.group(2)
                new_line = f"== {title}\n"

                if new_line != line:
                    changes_made = True
                    print(f"  -> FORCED first heading to '=='.")

                modified_lines.append(new_line)
                first_heading_found = True
            else:
                # Subsequent headings are appended as they are
                modified_lines.append(line)

        # 3. Aggressive Blank Line/Clutter Removal
        elif not first_heading_found:
            # If we haven't hit the first heading yet, check for content that might confuse Asciidoctor.
            if line_stripped == "":
                # Skip blank lines (they often cause the line number confusion)
                changes_made = True
                continue

            # The script assumes content that is NOT a heading and NOT blank should be kept
            # if it's part of the front matter block (already handled) or is the actual content.
            # If it's outside the front matter and before the first heading, it's problematic.
            # We will rely on Asciidoctor's processing of the content.
            modified_lines.append(line)

        else:
            # Append regular content after the first heading is fixed
            modified_lines.append(line)

    # Write back to file only if changes were made
    if changes_made:
        try:
            with open(filepath, 'w', encoding='utf-8') as f:
                f.writelines(modified_lines)
            print(f"  -> Successfully applied aggressive fix.")
        except Exception as e:
            print(f"  -> Error writing to {filepath}: {e}")
    else:
        print(f"  -> No changes needed.")


def main():
    """Main function to find and process files."""
    files_to_process = []

    print(f"Starting aggressive targeted script in directory: {os.getcwd()}")

    for pattern in FILE_PATTERNS:
        files_to_process.extend(glob(pattern, recursive=True))

    unique_files = sorted(list(set(files_to_process)))

    if not unique_files:
        print("\n❌ **No '07_memory/index_en.adoc' files found.**")
        return

    print(f"\n✅ Found {len(unique_files)} files to process.")
    print("--------------------------------------------------")

    for filepath in unique_files:
        if os.path.isfile(filepath):
            fix_06_memory_sequence_aggressive(filepath)

    print("--------------------------------------------------")
    print("Script finished. If this doesn't work, manual inspection is required.")


if __name__ == "__main__":
    main()