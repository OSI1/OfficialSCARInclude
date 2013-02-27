unit SCARApi;

interface

//**
// By Frédéric Hannes (http://www.scar-divi.com)
// License: http://creativecommons.org/licenses/by/3.0/
// -
// Wrappers for the SCAR export API, if you know what you're doing
// it might be better to use the export API directly. The export
// API is located in SCARLibSetup.pas. Not all exported functions
// wrapped in this file either.
//**

uses
  Vcl.Graphics, Windows, SCARUtils;

function SCAR_Version: Integer;
procedure SCAR_DebugLn(const Str: WideString); overload;
procedure SCAR_DebugLn(const Str: AnsiString); overload;

type
  TSCARBitmapWrapper = class
  private
    FBmpObj: Pointer;
    FOwnsObject: Boolean;
    function GetAlphaBlend: Boolean;
    function GetBits: PSCARBmpDataArray;
    function GetCanvas: TCanvas;
    function GetDC: HDC;
    function GetHeight: Integer;
    function GetPixels(const X, Y: Integer): Integer;
    function GetTranspColor: Integer;
    function GetWidth: Integer;
    procedure SetAlphaBlend(const Value: Boolean);
    procedure SetHeight(const Value: Integer);
    procedure SetPixels(const X, Y, Value: Integer);
    procedure SetTranspColor(const Value: Integer);
    procedure SetWidth(const Value: Integer);
  public
    constructor Create(const BmpObj: Pointer); overload;
    constructor Create; overload;
    destructor Destroy; override;

    procedure SetSize(const NewWidth, NewHeight: Integer);
    procedure Resize(const NewWidth, NewHeight: Integer);

    function Clone: TSCARBitmapWrapper;
    procedure Assign(const Obj: TObject);
    procedure AssignTo(const Obj: TObject);
    procedure Clear(const Color: Integer);

    function LoadFromBmp(const Path: WideString): Boolean; overload;
    function LoadFromBmp(const Path: AnsiString): Boolean; overload;
    function SaveToBmp(const Path: WideString): Boolean; overload;
    function SaveToBmp(const Path: AnsiString): Boolean; overload;
    function LoadFromPng(const Path: WideString): Boolean; overload;
    function LoadFromPng(const Path: AnsiString): Boolean; overload;
    function SaveToPng(const Path: WideString): Boolean; overload;
    function SaveToPng(const Path: AnsiString): Boolean; overload;
    function LoadFromJpeg(const Path: WideString): Boolean; overload;
    function LoadFromJpeg(const Path: AnsiString): Boolean; overload;
    function SaveToJpeg(const Path: WideString; const Quality: Integer): Boolean; overload;
    function SaveToJpeg(const Path: AnsiString; const Quality: Integer): Boolean; overload;

    procedure LoadFromStr(const DataStr: AnsiString);
    function SaveToStr: AnsiString;

    procedure Flip(const Horizontal: Boolean);
    procedure Rotate(const Angle: Extended);

    procedure SetAlphaMask(const Mask: TSCARBitmapWrapper); overload;
    procedure SetAlphaMask(const Mask: Pointer); overload;
    function GetAlphaMask: TSCARBitmapWrapper;

    procedure DrawTo(const Bmp: TSCARBitmapWrapper; const X, Y: Integer); overload;
    procedure DrawTo(const Bmp: Pointer; const X, Y: Integer); overload;
    procedure DrawToEx(const Bmp: TSCARBitmapWrapper; const X1, Y1, X2, Y2: Integer); overload;
    procedure DrawToEx(const Bmp: Pointer; const X1, Y1, X2, Y2: Integer); overload;

    property Canvas: TCanvas read GetCanvas;
    property DC: HDC read GetDC;
    property Width: Integer read GetWidth write SetWidth;
    property Height: Integer read GetHeight write SetHeight;
    property Bits: PSCARBmpDataArray read GetBits;
    property TranspColor: Integer read GetTranspColor write SetTranspColor;
    property Pixels[const X, Y: Integer]: Integer read GetPixels write SetPixels;
    property AlphaBlend: Boolean read GetAlphaBlend write SetAlphaBlend;

    property BmpObj: Pointer read FBmpObj write FBmpObj;
    property OwnsObject: Boolean read FOwnsObject write FOwnsObject;
  end;

implementation

uses
  SysUtils, Classes, SCARLibSetup;

function SCAR_Version: Integer;
begin
  Result := 0;
  if (Exp <> nil) and (@Exp^.Version <> nil) then
    Result := Exp^.Version;
end;

procedure SCAR_DebugLn(const Str: WideString); overload;
begin
  if (Exp <> nil) and (@Exp^.DebugLn <> nil) then
    Exp^.DebugLn(PWideChar(Str));
end;

procedure SCAR_DebugLn(const Str: AnsiString); overload;
begin
  if (Exp <> nil) and (@Exp^.DebugLnA <> nil) then
    Exp^.DebugLnA(PAnsiChar(Str));
end;

function SCAR_AppPath: string;
begin
  Result := '';
  if (Exp <> nil) and (@Exp^.AppPath <> nil) then
    Result := Exp^.AppPath;
end;

function SCAR_ScriptPath: string;
begin
  Result := '';
  if (Exp <> nil) and (@Exp^.ScriptPath <> nil) then
    Result := Exp^.ScriptPath;
end;

function SCAR_ScriptFileName: string;
begin
  Result := '';
  if (Exp <> nil) and (@Exp^.ScriptFileName <> nil) then
    Result := Exp^.ScriptFileName;
end;

function SCAR_IncludesPath: string;
begin
  Result := '';
  if (Exp <> nil) and (@Exp^.IncludesPath <> nil) then
    Result := Exp^.IncludesPath;
end;

function SCAR_FontsPath: string;
begin
  Result := '';
  if (Exp <> nil) and (@Exp^.FontsPath <> nil) then
    Result := Exp^.FontsPath;
end;

function SCAR_LogsPath: string;
begin
  Result := '';
  if (Exp <> nil) and (@Exp^.LogsPath <> nil) then
    Result := Exp^.LogsPath;
end;

function SCAR_WorkspacePath: string;
begin
  Result := '';
  if (Exp <> nil) and (@Exp^.WorkspacePath <> nil) then
    Result := Exp^.WorkspacePath;
end;

function SCAR_ScreenPath: string;
begin
  Result := '';
  if (Exp <> nil) and (@Exp^.ScreenPath <> nil) then
    Result := Exp^.ScreenPath;
end;

{ TSCARBitmapWrapper }

procedure TSCARBitmapWrapper.Assign(const Obj: TObject);
var
  Wrapper: TSCARBitmapWrapper absolute Obj;
begin
  if (FBmpObj <> nil) and Assigned(Obj) then
    if (Exp <> nil) and (@Exp^.TSCARBitmap_Assign <> nil) then
      if (Obj is TSCARBitmapWrapper) and (Wrapper.FBmpObj <> nil) then
        Exp^.TSCARBitmap_Assign(FBmpObj, TObject(Wrapper.FBmpObj))
      else if Obj is TPersistent then
        Exp^.TSCARBitmap_Assign(FBmpObj, Obj);
end;

procedure TSCARBitmapWrapper.AssignTo(const Obj: TObject);
var
  Wrapper: TSCARBitmapWrapper absolute Obj;
begin
  if (FBmpObj <> nil) and Assigned(Obj) then
    if (Exp <> nil) and (@Exp^.TSCARBitmap_AssignTo <> nil) then
      if (Obj is TSCARBitmapWrapper) and (Wrapper.FBmpObj <> nil) then
        Exp^.TSCARBitmap_AssignTo(FBmpObj, TObject(Wrapper.FBmpObj))
      else if Obj is TPersistent then
        Exp^.TSCARBitmap_AssignTo(FBmpObj, Obj);
end;

procedure TSCARBitmapWrapper.Clear(const Color: Integer);
begin
  if (FBmpObj <> nil) and (Exp <> nil) and (@Exp^.TSCARBitmap_Clear <> nil) then
    Exp^.TSCARBitmap_Clear(FBmpObj, Color);
end;

function TSCARBitmapWrapper.Clone: TSCARBitmapWrapper;
begin
  Result := nil;
  if (FBmpObj <> nil) and (Exp <> nil) and (@Exp^.TSCARBitmap_Clear <> nil) then
    Result := TSCARBitmapWrapper.Create(Exp^.TSCARBitmap_Clone(FBmpObj));
end;

constructor TSCARBitmapWrapper.Create;
begin
  FOwnsObject := False;
  if (Exp <> nil) and (@Exp^.TSCARBitmap_Create <> nil) then
    FBmpObj := Exp^.TSCARBitmap_Create;
end;

constructor TSCARBitmapWrapper.Create(const BmpObj: Pointer);
begin
  FOwnsObject := False;
  FBmpObj := BmpObj;
end;

destructor TSCARBitmapWrapper.Destroy;
begin
  if FOwnsObject and (FBmpObj <> nil) and (Exp <> nil) and (@Exp^.TSCARBitmap_Free <> nil) then
    Exp^.TSCARBitmap_Free(FBmpObj);
end;

procedure TSCARBitmapWrapper.DrawTo(const Bmp: Pointer; const X, Y: Integer);
begin
  if (FBmpObj <> nil) and (Bmp <> nil) and (Exp <> nil) and (@Exp^.TSCARBitmap_DrawTo <> nil) then
    Exp^.TSCARBitmap_DrawTo(FBmpObj, Bmp, X, Y);
end;

procedure TSCARBitmapWrapper.DrawTo(const Bmp: TSCARBitmapWrapper; const X, Y: Integer);
begin
  if (FBmpObj <> nil) and Assigned(Bmp) and (Bmp.FBmpObj <> nil) and (Exp <> nil) and (@Exp^.TSCARBitmap_DrawTo <> nil) then
    Exp^.TSCARBitmap_DrawTo(FBmpObj, Bmp.FBmpObj, X, Y);
end;

procedure TSCARBitmapWrapper.DrawToEx(const Bmp: Pointer; const X1, Y1, X2, Y2: Integer);
begin
  if (FBmpObj <> nil) and (Bmp <> nil) and (Exp <> nil) and (@Exp^.TSCARBitmap_DrawToEx <> nil) then
    Exp^.TSCARBitmap_DrawToEx(FBmpObj, Bmp, X1, Y1, X2, Y2);
end;

procedure TSCARBitmapWrapper.DrawToEx(const Bmp: TSCARBitmapWrapper; const X1, Y1, X2, Y2: Integer);
begin
  if (FBmpObj <> nil) and Assigned(Bmp) and (Bmp.FBmpObj <> nil) and (Exp <> nil) and (@Exp^.TSCARBitmap_DrawToEx <> nil) then
    Exp^.TSCARBitmap_DrawToEx(FBmpObj, Bmp.FBmpObj, X1, Y1, X2, Y2);
end;

procedure TSCARBitmapWrapper.Flip(const Horizontal: Boolean);
begin
  if (FBmpObj <> nil) and (Exp <> nil) and (@Exp^.TSCARBitmap_Flip <> nil) then
    Exp^.TSCARBitmap_Flip(FBmpObj, Horizontal);
end;

function TSCARBitmapWrapper.GetAlphaBlend: Boolean;
begin
  Result := False;
  if (FBmpObj <> nil) and (Exp <> nil) and (@Exp^.TSCARBitmap_Flip <> nil) then
    Result := Exp^.TSCARBitmap_GetAlphaBlend(FBmpObj);
end;

function TSCARBitmapWrapper.GetAlphaMask: TSCARBitmapWrapper;
begin
  Result := nil;
  if (FBmpObj <> nil) and (Exp <> nil) and (@Exp^.TSCARBitmap_Flip <> nil) then
    Result := TSCARBitmapWrapper.Create(Exp^.TSCARBitmap_GetAlphaMask(FBmpObj));
end;

function TSCARBitmapWrapper.GetBits: PSCARBmpDataArray;
begin
  Result := nil;
  if (FBmpObj <> nil) and (Exp <> nil) and (@Exp^.TSCARBitmap_Flip <> nil) then
    Result := Exp^.TSCARBitmap_GetBits(FBmpObj);
end;

function TSCARBitmapWrapper.GetCanvas: TCanvas;
begin
  Result := nil;
  if (FBmpObj <> nil) and (Exp <> nil) and (@Exp^.TSCARBitmap_Flip <> nil) then
    Result := Exp^.TSCARBitmap_GetCanvas(FBmpObj);
end;

function TSCARBitmapWrapper.GetDC: HDC;
begin
  Result := 0;
  if (FBmpObj <> nil) and (Exp <> nil) and (@Exp^.TSCARBitmap_Flip <> nil) then
    Result := Exp^.TSCARBitmap_GetDC(FBmpObj);
end;

function TSCARBitmapWrapper.GetHeight: Integer;
begin
  Result := 0;
  if (FBmpObj <> nil) and (Exp <> nil) and (@Exp^.TSCARBitmap_Flip <> nil) then
    Result := Exp^.TSCARBitmap_GetHeight(FBmpObj);
end;

function TSCARBitmapWrapper.GetPixels(const X, Y: Integer): Integer;
begin
  Result := 0;
  if (FBmpObj <> nil) and (Exp <> nil) and (@Exp^.TSCARBitmap_Flip <> nil) then
    Result := Exp^.TSCARBitmap_GetPixels(FBmpObj, X, Y);
end;

function TSCARBitmapWrapper.GetTranspColor: Integer;
begin
  Result := 0;
  if (FBmpObj <> nil) and (Exp <> nil) and (@Exp^.TSCARBitmap_Flip <> nil) then
    Result := Exp^.TSCARBitmap_GetTranspColor(FBmpObj);
end;

function TSCARBitmapWrapper.GetWidth: Integer;
begin
  Result := 0;
  if (FBmpObj <> nil) and (Exp <> nil) and (@Exp^.TSCARBitmap_Flip <> nil) then
    Result := Exp^.TSCARBitmap_GetWidth(FBmpObj);
end;

function TSCARBitmapWrapper.LoadFromBmp(const Path: AnsiString): Boolean;
begin
  Result := False;
  if (FBmpObj <> nil) and (Exp <> nil) and (@Exp^.TSCARBitmap_LoadFromBmpA <> nil) then
    Result := Exp^.TSCARBitmap_LoadFromBmpA(FBmpObj, PAnsiChar(Path));
end;

function TSCARBitmapWrapper.LoadFromBmp(const Path: WideString): Boolean;
begin
  Result := False;
  if (FBmpObj <> nil) and (Exp <> nil) and (@Exp^.TSCARBitmap_LoadFromBmp <> nil) then
    Result := Exp^.TSCARBitmap_LoadFromBmp(FBmpObj, PWideChar(Path));
end;

function TSCARBitmapWrapper.LoadFromJpeg(const Path: AnsiString): Boolean;
begin
  Result := False;
  if (FBmpObj <> nil) and (Exp <> nil) and (@Exp^.TSCARBitmap_LoadFromJpegA <> nil) then
    Result := Exp^.TSCARBitmap_LoadFromJpegA(FBmpObj, PAnsiChar(Path));
end;

function TSCARBitmapWrapper.LoadFromJpeg(const Path: WideString): Boolean;
begin
  Result := False;
  if (FBmpObj <> nil) and (Exp <> nil) and (@Exp^.TSCARBitmap_LoadFromJpeg <> nil) then
    Result := Exp^.TSCARBitmap_LoadFromJpeg(FBmpObj, PWideChar(Path));
end;

function TSCARBitmapWrapper.LoadFromPng(const Path: AnsiString): Boolean;
begin
  Result := False;
  if (FBmpObj <> nil) and (Exp <> nil) and (@Exp^.TSCARBitmap_LoadFromPngA <> nil) then
    Result := Exp^.TSCARBitmap_LoadFromPngA(FBmpObj, PAnsiChar(Path));
end;

procedure TSCARBitmapWrapper.LoadFromStr(const DataStr: AnsiString);
begin
  if (FBmpObj <> nil) and (Exp <> nil) and (@Exp^.TSCARBitmap_LoadFromStr <> nil) then
    Exp^.TSCARBitmap_LoadFromStr(FBmpObj, PAnsiChar(DataStr));
end;

function TSCARBitmapWrapper.LoadFromPng(const Path: WideString): Boolean;
begin
  Result := False;
  if (FBmpObj <> nil) and (Exp <> nil) and (@Exp^.TSCARBitmap_LoadFromPng <> nil) then
    Result := Exp^.TSCARBitmap_LoadFromPng(FBmpObj, PWideChar(Path));
end;

procedure TSCARBitmapWrapper.Resize(const NewWidth, NewHeight: Integer);
begin
  if (FBmpObj <> nil) and (Exp <> nil) and (@Exp^.TSCARBitmap_Clear <> nil) then
    Exp^.TSCARBitmap_Resize(FBmpObj, NewWidth, NewHeight);
end;

procedure TSCARBitmapWrapper.Rotate(const Angle: Extended);
begin
  if (FBmpObj <> nil) and (Exp <> nil) and (@Exp^.TSCARBitmap_Clear <> nil) then
    Exp^.TSCARBitmap_Rotate(FBmpObj, Angle);
end;

function TSCARBitmapWrapper.SaveToBmp(const Path: WideString): Boolean;
begin
  Result := False;
  if (FBmpObj <> nil) and (Exp <> nil) and (@Exp^.TSCARBitmap_SaveToBmpA <> nil) then
    Result := Exp^.TSCARBitmap_SaveToBmpA(FBmpObj, PAnsiChar(Path));
end;

function TSCARBitmapWrapper.SaveToBmp(const Path: AnsiString): Boolean;
begin
  Result := False;
  if (FBmpObj <> nil) and (Exp <> nil) and (@Exp^.TSCARBitmap_SaveToBmp <> nil) then
    Result := Exp^.TSCARBitmap_SaveToBmp(FBmpObj, PWideChar(Path));
end;

function TSCARBitmapWrapper.SaveToJpeg(const Path: WideString; const Quality: Integer): Boolean;
begin
  Result := False;
  if (FBmpObj <> nil) and (Exp <> nil) and (@Exp^.TSCARBitmap_SaveToJpegA <> nil) then
    Result := Exp^.TSCARBitmap_SaveToJpegA(FBmpObj, PAnsiChar(Path), Quality);
end;

function TSCARBitmapWrapper.SaveToJpeg(const Path: AnsiString; const Quality: Integer): Boolean;
begin
  Result := False;
  if (FBmpObj <> nil) and (Exp <> nil) and (@Exp^.TSCARBitmap_SaveToJpeg <> nil) then
    Result := Exp^.TSCARBitmap_SaveToJpeg(FBmpObj, PWideChar(Path), Quality);
end;

function TSCARBitmapWrapper.SaveToPng(const Path: AnsiString): Boolean;
begin
  Result := False;
  if (FBmpObj <> nil) and (Exp <> nil) and (@Exp^.TSCARBitmap_SaveToPngA <> nil) then
    Result := Exp^.TSCARBitmap_SaveToPngA(FBmpObj, PAnsiChar(Path));
end;

function TSCARBitmapWrapper.SaveToStr: AnsiString;
var
  Res: PAnsiChar;
begin
  if (FBmpObj <> nil) and (Exp <> nil) and (@Exp^.TSCARBitmap_SaveToPngA <> nil) then
  begin
    Exp^.TSCARBitmap_SaveToStr(FBmpObj, Res);
    SetLength(Result, StrLen(Res));
    StrCopy(@Result[1], Res);
  end;
end;

function TSCARBitmapWrapper.SaveToPng(const Path: WideString): Boolean;
begin
  Result := False;
  if (FBmpObj <> nil) and (Exp <> nil) and (@Exp^.TSCARBitmap_SaveToPng <> nil) then
    Result := Exp^.TSCARBitmap_SaveToPng(FBmpObj, PWideChar(Path));
end;

procedure TSCARBitmapWrapper.SetAlphaMask(const Mask: TSCARBitmapWrapper);
begin
  if (FBmpObj <> nil) and Assigned(Mask) and (Mask.FBmpObj <> nil) and (Exp <> nil) and (@Exp^.TSCARBitmap_SetAlphaMask <> nil) then
    Exp^.TSCARBitmap_SetAlphaMask(FBmpObj, Mask.FBmpObj);
end;

procedure TSCARBitmapWrapper.SetAlphaBlend(const Value: Boolean);
begin
  if (FBmpObj <> nil) and (Exp <> nil) and (@Exp^.TSCARBitmap_Flip <> nil) then
    Exp^.TSCARBitmap_SetAlphaBlend(FBmpObj, Value);
end;

procedure TSCARBitmapWrapper.SetAlphaMask(const Mask: Pointer);
begin
  if (FBmpObj <> nil) and (Mask <> nil) and (Exp <> nil) and (@Exp^.TSCARBitmap_SetAlphaMask <> nil) then
    Exp^.TSCARBitmap_SetAlphaMask(FBmpObj, Mask);
end;

procedure TSCARBitmapWrapper.SetHeight(const Value: Integer);
begin
  if (FBmpObj <> nil) and (Exp <> nil) and (@Exp^.TSCARBitmap_Flip <> nil) then
    Exp^.TSCARBitmap_SetHeight(FBmpObj, Value);
end;

procedure TSCARBitmapWrapper.SetPixels(const X, Y, Value: Integer);
begin
  if (FBmpObj <> nil) and (Exp <> nil) and (@Exp^.TSCARBitmap_Flip <> nil) then
    Exp^.TSCARBitmap_SetPixels(FBmpObj, X, Y, Value);
end;

procedure TSCARBitmapWrapper.SetSize(const NewWidth, NewHeight: Integer);
begin
  if (FBmpObj <> nil) and (Exp <> nil) and (@Exp^.TSCARBitmap_Clear <> nil) then
    Exp^.TSCARBitmap_SetSize(FBmpObj, NewWidth, NewHeight);
end;

procedure TSCARBitmapWrapper.SetTranspColor(const Value: Integer);
begin
  if (FBmpObj <> nil) and (Exp <> nil) and (@Exp^.TSCARBitmap_Flip <> nil) then
    Exp^.TSCARBitmap_SetTranspColor(FBmpObj, Value);
end;

procedure TSCARBitmapWrapper.SetWidth(const Value: Integer);
begin
  if (FBmpObj <> nil) and (Exp <> nil) and (@Exp^.TSCARBitmap_Flip <> nil) then
    Exp^.TSCARBitmap_SetWidth(FBmpObj, Value);
end;

end.

