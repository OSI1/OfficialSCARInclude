// Created By LordJashin for SCAR Divi
// All Bass code is from the Bass Library @ http://www.un4seen.com/
// NON Commercial, or you have to purchase a license from BASS for use
// Last Modified: 11/4/2012

library BassForSCAR;

uses
  FastShareMem in 'Units\FastShareMem.pas',
  SCARLibSetup in 'Units\SCARLibSetup.pas',
  SCARUtils in 'Units\SCARUtils.pas',
  SCARApi in 'Units\SCARApi.pas',
  Vcl_Rtl in 'Units\Vcl_Rtl.pas',
  bass in 'bass.pas',
  Winapi.Windows;

var
    Lib_Bass_DLL: THandle = 0;
    Lib_Bass_MusicStream: HSTREAM;
    Lib_Bass_SimultStream: array[0..128] of HSTREAM;
    Lib_Bass_SimultCount: Integer;
    Lib_Bass_DLLisLoaded: Boolean;

// Returns true if bass dll was loaded & initialized using Lib_Bass_Init
function Lib_Bass_IsLoaded: Boolean; stdcall;
begin
  Result := Lib_Bass_DLLisLoaded;
end;

// Loads bass library from path
function Lib_Bass_Init(PathToBassDLL: string): Boolean; stdcall;
begin
  Result := False;
  if Lib_Bass_DLL = 0 then
    Lib_Bass_DLL := LoadLibrary(PChar(PathToBassDLL));
  Result := Lib_Bass_DLL <> 0;
  // Initialize audio - default device, 44100hz, stereo, 16 bits
  if not BASS_Init(-1, 44100, 0, 0, nil) then Exit;
  Lib_Bass_SimultCount := 0; // stream count
  Lib_Bass_DLLisLoaded := True;
end;

// Plays sound from path
function Lib_Bass_PlaySound(Path: string): Boolean; stdcall;
begin
  Result := False;
  if not Lib_Bass_DLLisLoaded then Exit;
  if (BASS_ChannelIsActive(Lib_Bass_MusicStream) > 0) then Exit;
  Lib_Bass_MusicStream := BASS_StreamCreateFile(False, PChar(Path), 0, 0, 0 {$IFDEF UNICODE} or BASS_UNICODE {$ENDIF});
  if BASS_ChannelPlay(Lib_Bass_MusicStream, False) then
    Result := True;
end;

// Stops all sound
function Lib_Bass_StopSound: Boolean; stdcall;
var
  i: Integer;
begin
  Result := False;
  if not Lib_Bass_DLLisLoaded then Exit;
  BASS_ChannelStop(Lib_Bass_MusicStream);
  for i := 0 to High(Lib_Bass_SimultStream) do
    BASS_ChannelStop(Lib_Bass_SimultStream[i]);
  Lib_Bass_SimultCount := 0;
  Result := True;
end;

// Can load more than one stream into the sound playing Simultaneous Sound
function Lib_Bass_PlaySoundSimult(Path: string): Boolean; stdcall;
begin
  Result := False;
  if Lib_Bass_SimultCount = high(Lib_Bass_SimultStream) then
    Lib_Bass_SimultCount := 0;
  if Lib_Bass_SimultStream[Lib_Bass_SimultCount] > 0 then
    BASS_ChannelStop(Lib_Bass_SimultStream[Lib_Bass_SimultCount]);
  Lib_Bass_SimultStream[Lib_Bass_SimultCount] := BASS_StreamCreateFile(False, PChar(Path), 0, 0, 0 {$IFDEF UNICODE} or BASS_UNICODE {$ENDIF});
  if BASS_ChannelPlay(Lib_Bass_SimultStream[Lib_Bass_SimultCount], False) then
  Inc(Lib_Bass_SimultCount);
  Result := True;
end;

//--SCAR Library Code---------------------------------------------------------->

procedure OnLoadLib(const SCARExports: PExports); stdcall; export;
begin
  Exp := SCARExports; // Do NOT remove this line!
  // Called when the library is loaded
end;

procedure OnUnloadLib; stdcall;
begin
  // Called when the library is unloaded
   if Lib_Bass_DLL > 0 then
    FreeLibrary(Lib_Bass_DLL);
end;

// - Function exports
function OnGetFuncCount: Integer; stdcall;
begin
  Result := 5;
end;

function OnGetFuncInfo(const Idx: Integer; out ProcAddr: Pointer; out ProcDef: PAnsiChar;
  out CallConv: TCallConv): Integer; stdcall;
begin
  Result := Idx;
  case Idx of
    0: begin
      ProcAddr := @Lib_Bass_IsLoaded;
      ProcDef := 'function Lib_Bass_IsLoaded: Boolean; stdcall;';
      CallConv := ccStdCall;
    end;
    1: begin
      ProcAddr := @Lib_Bass_Init;
      ProcDef := 'function Lib_Bass_Init(PathToBassDLL: string): Boolean;';
      CallConv := ccStdCall;
    end;
    2: begin
      ProcAddr := @Lib_Bass_PlaySound;
      ProcDef := 'function Lib_Bass_PlaySound(Path: string): Boolean;';
      CallConv := ccStdCall;
    end;
    3: begin
      ProcAddr := @Lib_Bass_StopSound;
      ProcDef := 'function Lib_Bass_StopSound: Boolean;';
      CallConv := ccStdCall;
    end;
    4: begin
      ProcAddr := @Lib_Bass_PlaySoundSimult;
      ProcDef := 'function Lib_Bass_PlaySoundSimult(Path: string): Boolean;';
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
      TypeName := 'ZzZzZZZzZZzz123';
      TypeDef := '(z0, z1, z2);';
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

