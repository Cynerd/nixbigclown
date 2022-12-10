{
  buildPythonApplication,
  lib,
  fetchFromGitHub,
  appdirs,
  click,
  click-log,
  paho-mqtt,
  pyaml,
  pyserial,
  schema,
  simplejson,
}:
buildPythonApplication rec {
  pname = "bigclown-gateway";
  version = "1.17.0";
  meta = with lib; {
    homepage = "https://github.com/hardwario/bch-gateway";
    description = "HARDWARIO Gateway (Python Application «bcg»)";
    platforms = platforms.linux;
    license = licenses.mit;
  };

  propagatedBuildInputs = [
    appdirs
    click
    click-log
    paho-mqtt
    pyaml
    pyserial
    schema
    simplejson
  ];

  src = fetchFromGitHub {
    owner = "hardwario";
    repo = "bch-gateway";
    rev = "v${version}";
    sha256 = "2Yh5MeIv+BIxjoO9GOPqq7xTAFhyBvnxPy7DeO2FrkI=";
  };
}
