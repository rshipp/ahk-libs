AHK Lib v2
==========

Outline
-------

- Must be centralized and secure so code can be trusted.
- But also must be easy to submit, and easy to accept submissions.
- Peer elected maintainers review submissions. Less chance of 
- Transparent processes are key.

Code Style Guidelines
---------------------

- Clean, well structured code.
- Code must be wrapped in functions/classes with clear, non-conflicting namespaces.
- Code must not depend on positioning of #include.
- Prefer code without side effects. (e.g. unnecessarily and unexpectedly polluting or relying on the global namespace.)
- Consistent indentation. (4 spaces per indentation?)
- Consistent brace style. ([Allman](http://en.wikipedia.org/wiki/Indent_style#Allman_style) ?)
- Exposed interfaces should be documented in a standard way. (doxygen or gendocs?).
- Exposed interfaces should be mostly stable and not change.
- Usage examples should be provided.
- Forum topic on AutoHotkey.com. (keep the centralized support)

Submission
----------

- Any script can be submitted for review, and must meet all requirements in the Code Style Guidelines section.
- All scripts MUST be submitted with a licence and it MUST be included at the top of all files submitted.
- Group members will peer review the code for style and robustness.
- Script author is included in the process.
- Any issues found can be fixed and the script reevaluated.
- Two peer reviews to make sure any errors are caught early on.
- Eighty percent majority approval for new scripts to be added into central repository.

Repository
----------

- Automatic download script(s).
- Autoupdate to the latest for the branch (Basic, L, etc.).
- Separate branches for each version of AHK (basic, L, v2, etc.).
- Versions: (say a new version makes breaking changes) Separate files: SuperLib.ahk, SuperLib2.ahk; major versions only.
- Script author may commit short bug fixes with streamlined review process (only one review needed).
- 

Maintainers
-----------

- (This might be easier with something like [gerrit](http://code.google.com/p/gerrit/), though more complicated.  Future maybe?)
- Maintainers should seek public opinion on key decisions whenever possible.