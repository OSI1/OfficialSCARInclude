{=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
                            MoreKeyboardFunctions.dll
                              For SCAR Divi & OSI
                     License: Everyone can use it regardless

        Description: This extends SCAR by adding
                     more keyboard functions to it.
                     This is a DLL file that should be
                     loaded by SCAR Divi.
--------------------------------------------------------------------------------

 This is delphi code, if you want to modify anything. Do it inside the functions
 or procedures themselves. If you change something crucial it could keep it from
 exporting to SCAR correctly. Leave the SCARLibSetup.pas, FastShareMem.pas, and
 SCARUtils.pas files alone. These files are crucial to having a SCAR dll plugin.

 All the ones with STDCALL on the end of them are exported to SCAR when loaded

 Note that all of these pretty much do the same thing. THEY DO NOT WORK WITH
 CHARACTERS e.g. NO USING CharToVkey

 * procedure VKKeybdDown(VKey: Byte); stdcall;
 * procedure VKKeybdUp(VKey: Byte); stdcall;
 * function  SetupKeyInput(VKey: Byte; Flags: DWORD): TInput;
 * function  VKSendKeyDown(VKey: Byte): Boolean; stdcall;
 * function  VKSendKeyUp(VKey: Byte): Boolean; stdcall;
=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=}

library MoreKeyboardFunctions;

uses
  FastShareMem in 'Units\FastShareMem.pas',
  System.SysUtils,
  System.Classes,
  Winapi.Windows,
  Winapi.Messages,
  SCARLibSetup in 'Units\SCARLibSetup.pas',
  SCARUtils in 'Units\SCARUtils.pas';

{$R *.res}


function SetupKeyInput2(DKey: Word; Flags: DWORD): TInput;
begin
  Result.Itype := INPUT_KEYBOARD;
  Result.ki.wScan := DKey;
  with Result.ki do
  begin
    dwFlags := Flags or KEYEVENTF_SCANCODE;
    time := 0;
    dwExtraInfo := 0;
  end;
end;

procedure SendDirKeyDown(DKey: Word); stdcall;
var
  InputData: TInput;
begin
  InputData := SetupKeyInput2(DKey, 0);
// Send Keyup flag "OR"ed with Scancode flag for keyup to work properly
  SendInput(1, InputData, SizeOf(InputData));
end;

procedure SendDirKeyUp(DKey: Word); stdcall;
var
  InputData: TInput;
begin
  InputData := SetupKeyInput2(DKey, KEYEVENTF_KEYUP);
// Send Keyup flag "OR"ed with Scancode flag for keyup to work properly
  SendInput(1, InputData, SizeOf(InputData));
end;

procedure VKKeybdDown(VKey: Byte); stdcall;
begin
  keybd_event(0, MapvirtualKey(VKey, MAPVK_VK_TO_VSC_EX), 0, 0);
end;

procedure VKKeybdUp(VKey: Byte); stdcall;
begin
  keybd_event(0, MapvirtualKey(VKey, MAPVK_VK_TO_VSC_EX), KEYEVENTF_KEYUP, 0);
end;

function SetupKeyInput(VKey: Byte; Flags: DWORD): TInput; stdcall;
begin
  Result.Itype := INPUT_KEYBOARD;
  Result.ki.wScan := MapVirtualKey(VKey, MAPVK_VK_TO_VSC_EX);
  with Result.ki do
  begin
    dwFlags := Flags;
    time := 0;
    dwExtraInfo := 0;
  end;
end;

// Uses sendinput; KeyDown with SCANCODES

function VKSendKeyDown(VKey: Byte): Boolean; stdcall;
var
  T: TInput;
begin
  Result := False;
  T := SetupKeyInput(Vkey, 0);
  if (SendInput(1, T, SizeOf(T)) > 0) then
    Result := True;
end;

// Uses sendinput; KeyUp with SCANCODES

function VKSendKeyUp(VKey: Byte): Boolean; stdcall;
var
  T: TInput;
begin
  Result := False;
  T := SetupKeyInput(Vkey, KEYEVENTF_KEYUP);
  if (SendInput(1, T, SizeOf(T)) > 0) then
    Result := True;
end;

// Uses SendInput; to send a string of text

procedure OnLoadLib(const SCARExports: PExports); stdcall; export;
begin
  Exp := SCARExports; // Do NOT remove this line!
  // Called when the library is loaded
end;

procedure OnUnloadLib; stdcall;
begin
  // Called when the library is unloaded
end;

// - Function exports
function OnGetFuncCount: Integer; stdcall;
begin
  Result := 6;
end;

function OnGetFuncInfo(const Idx: Integer; out ProcAddr: Pointer; out ProcDef: PAnsiChar;
  out CallConv: TCallConv): Integer; stdcall;
begin
  Result := Idx;
  case Idx of
    0: begin
      ProcAddr := @VKKeybdDown;
      ProcDef := 'procedure VKKeybdDown(VKey: Byte);';
      CallConv := ccStdCall;
    end;
    1: begin
      ProcAddr := @VKKeybdUp;
      ProcDef := 'procedure VKKeybdUp(VKey: Byte);';
      CallConv := ccStdCall;
    end;
    2: begin
      ProcAddr := @VKSendKeyDown;
      ProcDef := 'function VKSendKeyDown(VKey: Byte): Boolean;';
      CallConv := ccStdCall;
    end;
    3: begin
      ProcAddr := @VKSendKeyUp;
      ProcDef := 'function VKSendKeyUp(VKey: Byte): Boolean;';
      CallConv := ccStdCall;
    end;
    4: begin
      ProcAddr := @SendDirKeyDown;
      ProcDef := 'procedure SendDirKeyDown(DKey: Word);';
      CallConv := ccStdCall;
    end;
    5: begin
      ProcAddr := @SendDirKeyUp;
      ProcDef := 'procedure SendDirKeyUp(DKey: Word);';
      CallConv := ccStdCall;
    end
    else Result := -1;
  end;
end;

// - Type exports
function OnGetTypeCount: Integer; stdcall;
begin
  Result := 0;
end;

function OnGetTypeInfo(const Idx: Integer; out TypeName, TypeDef: PAnsiChar): Integer; stdcall;
begin
  Result := Idx;
  case Idx of
    0: begin
      {TypeName := 'DIKeyboard';
      TypeDef := 'record';}
    end
    else Result := -1;
  end;
end;

// - Library architecture
// Do NOT change this!
const
  LIBRARY_ARCHITECTURE_LEGACY = 1;
  LIBRARY_ARCHITECTURE_MAIN   = 2;

function LibArch: Integer; stdcall;
begin
  Result := LIBRARY_ARCHITECTURE_MAIN;
end;

exports OnLoadLib;
exports OnUnloadLib;
exports OnGetFuncCount;
exports OnGetFuncInfo;
exports OnGetTypeCount;
exports OnGetTypeInfo;
exports LibArch;

end.
