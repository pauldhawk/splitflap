# claude config questions

1. Build system expects it - The platformio.ini file is at the root, and all the PlatformIO commands in the CLAUDE.md are designed to run from there:
   pio run -e chainlink # Not: cd firmware && pio run
2. Cross-component dependencies - Even when working on firmware, you might need:

    - Protobuf definitions in proto/
    - Shared libraries in firmware/lib/
    - Documentation in docs/

3. I can still focus narrowly - When you tell me "I need to update the firmware," I can:

    - Limit my searches to firmware/**/* patterns
    - Focus file reads on the firmware directory
    - Still have access to related files if needed

4. Git operations work naturally - Your git status shows you're already working with the whole repo for version control

That said, when you're working on firmware specifically, just let me know and I'll keep my focus on the firmware/ directory and related files. The full repo context actually helps me understand dependencies and avoid breaking things.
