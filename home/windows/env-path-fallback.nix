{ lib, pkgs }:

let
  # detect if running in WSL environment
  isWSLEnvironment = builtins.pathExists "/proc/version" && 
    lib.hasInfix "microsoft" (lib.toLower (builtins.readFile "/proc/version"));

  # get windows username from environment or fallback
  getWindowsUsername = fallbackUsername: 
    let
      # try to get from windows environment variables via wslpath
      userProfilePath = builtins.tryEval (
        lib.removeSuffix "\n" (builtins.readFile (
          pkgs.runCommand "get-windows-username" {} ''
            if command -v wslpath >/dev/null 2>&1; then
              # get windows user profile and extract username
              WIN_PROFILE=$(wslpath -w ~)
              echo "$WIN_PROFILE" | sed 's|.*\\Users\\||' | sed 's|\\.*||' > $out
            else
              echo "${fallbackUsername}" > $out
            fi
          ''
        ))
      );
    in
    if userProfilePath.success then userProfilePath.value else fallbackUsername;

  # convert WSL path to Windows path using wslpath
  toWindowsPath = wslPath:
    if isWSLEnvironment then
      lib.removeSuffix "\n" (builtins.readFile (
        pkgs.runCommand "convert-to-windows-path" {} ''
          if command -v wslpath >/dev/null 2>&1; then
            wslpath -w "${wslPath}" > $out
          else
            echo "${wslPath}" > $out
          fi
        ''
      ))
    else wslPath;

  # convert Windows path to WSL path using wslpath  
  fromWindowsPath = windowsPath:
    if isWSLEnvironment then
      lib.removeSuffix "\n" (builtins.readFile (
        pkgs.runCommand "convert-from-windows-path" {} ''
          if command -v wslpath >/dev/null 2>&1; then
            wslpath "${windowsPath}" > $out
          else
            echo "${windowsPath}" > $out
          fi
        ''
      ))
    else windowsPath;

  # get common Windows paths based on resolution method
  getWindowsPaths = windowsUsername: pathConfig:
    let
      method = pathConfig.method or "wslpath";
      manualPaths = pathConfig.manualPaths or {};
      
      # default path construction for different methods
      defaultPaths = {
        wslpath = {
          userProfile = fromWindowsPath "C:\\Users\\${windowsUsername}";
          appData = fromWindowsPath "C:\\Users\\${windowsUsername}\\AppData\\Roaming";
          localAppData = fromWindowsPath "C:\\Users\\${windowsUsername}\\AppData\\Local";
          documents = fromWindowsPath "C:\\Users\\${windowsUsername}\\Documents";
          desktop = fromWindowsPath "C:\\Users\\${windowsUsername}\\Desktop";
        };
        
        environment = {
          userProfile = "/mnt/c/Users/${windowsUsername}";
          appData = "/mnt/c/Users/${windowsUsername}/AppData/Roaming";
          localAppData = "/mnt/c/Users/${windowsUsername}/AppData/Local";
          documents = "/mnt/c/Users/${windowsUsername}/Documents";
          desktop = "/mnt/c/Users/${windowsUsername}/Desktop";
        };
        
        manual = manualPaths;
      };
      
      basePaths = defaultPaths.${method} or defaultPaths.environment;
    in
    basePaths // manualPaths; # manual paths override defaults

  # create a symlink that works across WSL-Windows boundary
  createCrossLink = { source, target, strategy ? "symlink" }:
    if strategy == "symlink" then {
      "${target}".source = source;
    } else if strategy == "copy" then {
      "${target}".source = source;
      "${target}".recursive = true;
    } else if strategy == "template" then {
      "${target}".text = builtins.readFile source;
    } else
      throw "Unknown file management strategy: ${strategy}";

  # validate that a Windows path exists and is accessible
  validateWindowsPath = path:
    builtins.pathExists path;

  # get Windows Terminal settings path
  getWindowsTerminalPath = windowsPaths:
    "${windowsPaths.localAppData}/Packages/Microsoft.WindowsTerminal_8wekyb3d8bbwe/LocalState/settings.json";

  # get PowerShell profile paths
  getPowerShellPaths = windowsPaths: {
    currentUser = "${windowsPaths.documents}/PowerShell/Microsoft.PowerShell_profile.ps1";
    currentUserISE = "${windowsPaths.documents}/PowerShell/Microsoft.PowerShellISE_profile.ps1";
    allUsers = "/mnt/c/Windows/System32/WindowsPowerShell/v1.0/profile.ps1";
  };

  # get VS Code settings paths
  getVSCodePaths = windowsPaths: {
    settings = "${windowsPaths.appData}/Code/User/settings.json";
    keybindings = "${windowsPaths.appData}/Code/User/keybindings.json";
    snippets = "${windowsPaths.appData}/Code/User/snippets";
    extensions = "${windowsPaths.localAppData}/Programs/Microsoft VS Code/resources/app/extensions";
  };

  # get Git configuration paths
  getGitPaths = windowsPaths: {
    globalConfig = "${windowsPaths.userProfile}/.gitconfig";
    systemConfig = "/mnt/c/Program Files/Git/etc/gitconfig";
  };

  # get SSH paths
  getSSHPaths = windowsPaths: {
    sshDir = "${windowsPaths.userProfile}/.ssh";
    knownHosts = "${windowsPaths.userProfile}/.ssh/known_hosts";
    config = "${windowsPaths.userProfile}/.ssh/config";
  };

  # create backup of existing file
  createBackup = filePath:
    let
      backupPath = "${filePath}.nix-backup";
    in
    pkgs.writeShellScript "backup-${baseNameOf filePath}" ''
      if [ -f "${filePath}" ] && [ ! -f "${backupPath}" ]; then
        echo "Creating backup: ${filePath} -> ${backupPath}"
        cp "${filePath}" "${backupPath}"
      fi
    '';

  # ensure directory exists
  ensureDirectory = dirPath:
    pkgs.writeShellScript "ensure-dir-${baseNameOf dirPath}" ''
      mkdir -p "${dirPath}"
    '';

  # get Windows font paths
  getFontPaths = windowsPaths: {
    userFonts = "${windowsPaths.localAppData}/Microsoft/Windows/Fonts";
    systemFonts = "/mnt/c/Windows/Fonts";
    fontRegistry = "HKCU:\\SOFTWARE\\Microsoft\\Windows NT\\CurrentVersion\\Fonts";
  };

  # validate font installation
  validateFontInstallation = fontName: windowsPaths:
    let
      fontPaths = getFontPaths windowsPaths;
    in
    builtins.pathExists fontPaths.userFonts &&
    (builtins.readDir fontPaths.userFonts) != {};

  # create font family string with fallbacks
  createFontFamily = primaryFont: fallbackFonts:
    "${primaryFont}, ${lib.concatStringsSep ", " fallbackFonts}, monospace";

in

{
  inherit
    isWSLEnvironment
    getWindowsUsername
    toWindowsPath
    fromWindowsPath
    getWindowsPaths
    createCrossLink
    validateWindowsPath
    getWindowsTerminalPath
    getPowerShellPaths
    getVSCodePaths
    getGitPaths
    getSSHPaths
    createBackup
    ensureDirectory
    getFontPaths
    validateFontInstallation
    createFontFamily;
}
