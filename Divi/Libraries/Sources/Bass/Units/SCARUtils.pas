unit SCARUtils;

interface

//**
// By Frédéric Hannes (http://www.scar-divi.com)
// License: http://creativecommons.org/licenses/by/3.0/
//**

uses
  Windows, Vcl.Controls;

type
  TCallConv = (ccRegister, ccPascal, ccCdecl, ccStdCall, ccSafeCall);

  TFunctionExport = record
    Ref: Pointer;
    Def: AnsiString;
    Conv: TCallConv;
  end;

  TTypeExport = record
    Name, Def: AnsiString;
  end;

  PSCARBmpData = ^TSCARBmpData;
  TSCARBmpData = record
    B, G, R, A: Byte;
  end;

  PSCARBmpDataArray = ^TSCARBmpDataArray;
  TSCARBmpDataArray = array[0..0] of TSCARBmpData;

  PLibClientCallbacks = ^TLibClientCallbacks;
  TLibClientCallbacks = record
    SetCursorPos: procedure(const Client: Pointer; const X, Y: Integer); stdcall;
    GetCursorPos: procedure(const Client: Pointer; out X, Y: Integer); stdcall;
    MouseBtnDown: procedure(const Client: Pointer; const Button: TMouseButton); stdcall;
    MouseBtnUp: procedure(const Client: Pointer; const Button: TMouseButton); stdcall;
    GetMouseBtnState: function(const Client: Pointer; const Btn: TMouseButton): Boolean; stdcall;
    VKeyDown: procedure(const Client: Pointer; const VKey: Byte); stdcall;
    VKeyUp: procedure(const Client: Pointer; const VKey: Byte); stdcall;
    KeyDown: procedure(const Client: Pointer; const Key: WideChar); stdcall;
    KeyUp: procedure(const Client: Pointer; const Key: WideChar); stdcall;
    GetKeyState: function(const Client: Pointer; const VKey: Byte): Boolean; stdcall;
    GetCurrentKeyState: function(const Client: Pointer; const VKey: Byte): Boolean; stdcall;
    GetToggleKeyState: function(const Client: Pointer; const VKey: Byte): Boolean; stdcall;
    Capture: procedure(const Client: Pointer; const DC: HDC; const XS, YS, XE, YE, DestX, DestY: Integer); stdcall;
    GetPixel: function(const Client: Pointer; const X, Y: Integer): Integer; stdcall;
    Activate: procedure(const Client: Pointer); stdcall;
    Clone: function(const Client: Pointer): Pointer; stdcall;
    Destroy: procedure(const Client: Pointer); stdcall;
    TypeText: procedure(const Client: Pointer; const Text: string; const PressIval, PressIvalRnd, ModIval, ModIvalRnd,
      CharIval, CharIvalRnd: Integer; const UseNumpad: Boolean); stdcall;
  end;

  PBox = ^TBox;
  TBox = record
    X1, Y1, X2, Y2: Integer;
  private
    function GetWidth: Integer;
    function GetHeight: Integer;
  public
    constructor Create(const X1, Y1, X2, Y2: Integer); overload;
    constructor Create(const Rect: TRect); overload;
    property Width: Integer read GetWidth;
    property Height: Integer read GetHeight;
    class operator Implicit(const Box: TBox): string;
    class operator Explicit(const Box: TBox): string;
  end;

implementation

uses
  SysUtils;

{ TBox }

constructor TBox.Create(const X1, Y1, X2, Y2: Integer);
begin
  Self.X1 := X1;
  Self.Y1 := Y1;
  Self.X2 := X2;
  Self.Y2 := Y2;
end;

constructor TBox.Create(const Rect: TRect);
begin
  Self.X1 := Rect.Left;
  Self.Y1 := Rect.Top;
  Self.X2 := Rect.Right - 1;
  Self.Y2 := Rect.Bottom - 1;
end;

class operator TBox.Explicit(const Box: TBox): string;
begin
  Result := '(' + IntToStr(Box.X1) + ', ' + IntToStr(Box.Y1) + ', ' +
    IntToStr(Box.X2) + ', ' + IntToStr(Box.Y2) + ')';
end;

function TBox.GetHeight: Integer;
begin
  Result := Y2 - Y1 + 1;
end;

function TBox.GetWidth: Integer;
begin
  Result := X2 - X1 + 1;
end;

class operator TBox.Implicit(const Box: TBox): string;
begin
  Result := '(' + IntToStr(Box.X1) + ', ' + IntToStr(Box.Y1) + ', ' +
    IntToStr(Box.X2) + ', ' + IntToStr(Box.Y2) + ')';
end;

end.

