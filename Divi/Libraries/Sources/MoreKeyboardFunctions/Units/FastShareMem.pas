unit FastShareMem;

//**
// By Frédéric Hannes (http://www.scar-divi.com)
// Based on FastShareMem by Emil M. Santos (http://www.codexterity.com)
// License: http://creativecommons.org/licenses/by/3.0/
//**

interface

implementation

uses
  Windows;

var
  WndClass: TWndClassA;
initialization
  if GetClassInfoA(HInstance, '_com.codexterity.fastsharemem.dataclass', WndClass) then
    SetMemoryManager(TMemoryManagerEx(WndClass.lpfnWndProc^));
end.
