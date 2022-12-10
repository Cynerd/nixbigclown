{
  buildPythonApplication,
  lib,
  fetchFromGitHub,
  influxdb,
  jsonpath-ng,
  paho-mqtt,
  py-expression-eval,
  pyaml,
  pycron,
  schema,
}:
buildPythonApplication rec {
  pname = "bigclown-mqtt2influxdb";
  # Note: this is not released version but we need new InfluxDB integration.
  version = "1.6.0-rc0";
  meta = with lib; {
    homepage = "https://github.com/hardwario/bch-mqtt2influxdb";
    description = "Flexible MQTT to InfluxDB Bridge";
    platforms = platforms.linux;
    license = licenses.mit;
  };

  propagatedBuildInputs = [
    influxdb
    jsonpath-ng
    paho-mqtt
    py-expression-eval
    pyaml
    pycron
    schema
  ];

  src = fetchFromGitHub {
    owner = "hardwario";
    repo = "bch-mqtt2influxdb";
    #rev = "v${version}";
    rev = "48c5bce75480d3b600d5b2d18d662a024ee7ea55";
    sha256 = "XEvyeTBGH/70sNgSELRETn8zshwwH8i07pdh3WzM8gg=";
  };
}
