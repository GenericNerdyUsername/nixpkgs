{ lib
, stdenv
, fetchurl
, cmake
, ninja
, tcl
, tk
, libGL
, libGLU
, libXext
, libXmu
, libXi
, vtk
, darwin
}:

stdenv.mkDerivation rec {
  pname = "opencascade-occt";
  version = "7.7.0";
  commit = "V${builtins.replaceStrings ["."] ["_"] version}";

  src = fetchurl {
    name = "occt-${commit}.tar.gz";
    url = "https://git.dev.opencascade.org/gitweb/?p=occt.git;a=snapshot;h=${commit};sf=tgz";
    hash = "sha256-aEWhf+X0CzaFpXG+l+VpZgXeI8x6vxD4pkTSFjcRxv8=";
  };

  nativeBuildInputs = [ cmake ninja ];
  buildInputs = [ tcl tk libGL libGLU libXext libXmu libXi vtk ]
    ++ lib.optional stdenv.isDarwin darwin.apple_sdk.frameworks.Cocoa;

  patches = [
    ./limits.patch
    (fetchurl {
      url = "https://src.fedoraproject.org/rpms/opencascade/raw/rawhide/f/opencascade-vtk.patch";
      hash = "sha256-UykWJ0tCnKmtLCRaLAJKDZhhfrlJ+dYi6S4zgbhkxBY=";
    })
  ];

  cmakeFlags = [
    "-DUSE_VTK=ON"
    "-D3RDPARTY_VTK_INCLUDE_DIR=${vtk}/include"
  ];

  meta = with lib; {
    description = "Open CASCADE Technology, libraries for 3D modeling and numerical simulation";
    homepage = "https://www.opencascade.org/";
    license = licenses.lgpl21; # essentially...
    # The special exception defined in the file OCCT_LGPL_EXCEPTION.txt
    # are basically about making the license a little less share-alike.
    maintainers = with maintainers; [ amiloradovsky gebner ];
    platforms = platforms.all;
  };

}
