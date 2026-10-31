{
  inputs,
  pkgs,
  ...
}: {
  environment.systemPackages = [
    inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.orca
    inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.antigravity-cli
    #inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.chatgpt
    inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.copilot-cli
    inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.zcode
    inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.opencode
  ];
}
