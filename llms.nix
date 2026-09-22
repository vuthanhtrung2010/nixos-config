{ inputs, pkgs, ... }:

{
  environment.systemPackages = [
    inputs.llm-agents.packages.${pkgs.system}.orca
    inputs.llm-agents.packages.${pkgs.system}.antigravity-cli
  ];
}