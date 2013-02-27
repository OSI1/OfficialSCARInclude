unit Vcl_Rtl;

//**
// By Frédéric Hannes (http://www.scar-divi.com)
// License: http://creativecommons.org/licenses/by/3.0/
// -
// This unit contains replacements for types and functions in Delphi's VCL and
// RTL libraries, with the purpose of being able to remove them from the project
// to reduce the binary filesize.
//**

interface

type
  TCanvas = TObject;
  TMouseButton = (mbLeft, mbRight, mbMiddle);

const
  PathDelim = '\';

implementation

end.

