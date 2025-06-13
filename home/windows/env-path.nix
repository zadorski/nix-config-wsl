{ lib, pkgs }:

let
  # enhanced Windows library with dynamic environment detection
  # this library maintains Nix purity while enabling runtime Windows environment detection

  # detect if running in WSL environment
  isWSLEnvironment = builtins.pathExists "/proc/version" && 
    lib.hasInfix "microsoft" (lib.toLower (builtins.readFile "/proc/version"));

  # read dynamic Windows environment from activation-generated file
  # note: this function returns empty set during evaluation time
  # environment variables are loaded at runtime via shell integration
  readWindowsEnvironment = {};

  # get Windows username with dynamic detection and fallbacks
  getWindowsUsername = fallbackUsername:
    let
      # fallback to wslvar detection during evaluation
      wslvarUsername = builtins.tryEval (
        lib.removeSuffix "\n" (builtins.readFile (
          pkgs.runCommand "get-windows-username-wslvar" {} ''
            if command -v wslvar >/dev/null 2>&1; then
              WIN_USER=$(wslvar USERNAME 2>/dev/null || echo "")
              if [ -n "$WIN_USER" ]; then
                echo "$WIN_USER" > $out
              else
                echo "${fallbackUsername}" > $out
              fi
            else
              echo "${fallbackUsername}" > $out
            fi
          ''
        ))
      );
    in
    if wslvarUsername.success then
      wslvarUsername.value
    else
      fallbackUsername;

  # get Windows paths with dynamic detection and fallbacks
  getDynamicWindowsPaths = fallbackUsername:
    let
      # during Nix evaluation, we use fallback paths
      # at runtime, the environment detection will provide actual paths
      dynamicUsername = getWindowsUsername fallbackUsername;
      
      # provide fallback paths for evaluation time
      # runtime detection will override these via environment variables
      fallbackPaths = {
        userProfile = "/mnt/c/Users/${dynamicUsername}";
        appData = "/mnt/c/Users/${dynamicUsername}/AppData/Roaming";
        localAppData = "/mnt/c/Users/${dynamicUsername}/AppData/Local";
        documents = "/mnt/c/Users/${dynamicUsername}/Documents";
        desktop = "/mnt/c/Users/${dynamicUsername}/Desktop";
        downloads = "/mnt/c/Users/${dynamicUsername}/Downloads";
        driveMount = "/mnt/c";
        windows = "/mnt/c/Windows";
        programFiles = "/mnt/c/Program Files";
        programFilesX86 = "/mnt/c/Program Files (x86)";
      };
    in
    fallbackPaths;

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

  # validate that a Windows path exists and is accessible
  validateWindowsPath = path:
    builtins.pathExists path;

  # get Windows Terminal settings path
  getWindowsTerminalPath = windowsPaths:
    "${windowsPaths.localAppData}/Packages/Microsoft.WindowsTerminal_8wekyb3d8bbwe/LocalState/settings.json";

  # get PowerShell profile paths with dynamic system paths
  getPowerShellPaths = windowsPaths: {
    currentUser = "${windowsPaths.documents}/PowerShell/Microsoft.PowerShell_profile.ps1";
    currentUserISE = "${windowsPaths.documents}/PowerShell/Microsoft.PowerShellISE_profile.ps1";
    allUsers = "${windowsPaths.windows}/System32/WindowsPowerShell/v1.0/profile.ps1";
  };

  # get VS Code settings paths
  getVSCodePaths = windowsPaths: {
    settings = "${windowsPaths.appData}/Code/User/settings.json";
    keybindings = "${windowsPaths.appData}/Code/User/keybindings.json";
    snippets = "${windowsPaths.appData}/Code/User/snippets";
    extensions = "${windowsPaths.localAppData}/Programs/Microsoft VS Code/resources/app/extensions";
  };

  # get Git configuration paths with dynamic system paths
  getGitPaths = windowsPaths: {
    globalConfig = "${windowsPaths.userProfile}/.gitconfig";
    systemConfig = "${windowsPaths.programFiles}/Git/etc/gitconfig";
  };

  # get SSH paths
  getSSHPaths = windowsPaths: {
    sshDir = "${windowsPaths.userProfile}/.ssh";
    knownHosts = "${windowsPaths.userProfile}/.ssh/known_hosts";
    config = "${windowsPaths.userProfile}/.ssh/config";
  };

  # get Windows font paths with dynamic system paths
  getFontPaths = windowsPaths: {
    userFonts = "${windowsPaths.localAppData}/Microsoft/Windows/Fonts";
    systemFonts = "${windowsPaths.windows}/Fonts";
    fontRegistry = "HKCU:\\SOFTWARE\\Microsoft\\Windows NT\\CurrentVersion\\Fonts";
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
    readWindowsEnvironment
    getWindowsUsername
    getDynamicWindowsPaths
    toWindowsPath
    fromWindowsPath
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
