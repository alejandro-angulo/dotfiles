{
  inputs,
  ...
}:
{
  imports = [
    inputs.den.flakeModule
    inputs.den.flakeOutputs.packages
  ];
}
