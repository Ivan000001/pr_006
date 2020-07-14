unit PluginManager;
 
interface

uses Windows;

type
  IPlugin = interface
  // protected
    function GetIndex: Integer;
    function GetHandle: HMODULE;
    function GetFileName: String;
  // public
    property Index: Integer read GetIndex;
    property Handle: HMODULE read GetHandle;
    property FileName: String read GetFileName;
  end;

  IPluginManager = interface
  // protected
    function GetItem(const AIndex: Integer): IPlugin;
    function GetCount: Integer;
  // public
    function LoadPlugin(const AFileName: String): IPlugin;
    procedure UnloadPlugin(const AIndex: Integer);
 
    property Items[const AIndex: Integer]: IPlugin read GetItem; default;
    property Count: Integer read GetCount;
  end;

function Plugins: IPluginManager;

implementation

uses
  SysUtils,
  Classes;

type
  TPluginManager = class(TInterfacedObject, IPluginManager)
  private
    FItems: array of IPlugin;
    FCount: Integer;
  protected
    function GetItem(const AIndex: Integer): IPlugin;
    function GetCount: Integer;
  public
    function LoadPlugin(const AFileName: String): IPlugin;
    procedure UnloadPlugin(const AIndex: Integer);
    function IndexOf(const APlugin: IPlugin): Integer;
  end;
 
  TPlugin = class(TInterfacedObject, IPlugin)
  private
    FManager: TPluginManager;
    FFileName: String;
    FHandle: HMODULE;
  protected
    function GetIndex: Integer;
    function GetHandle: HMODULE;
    function GetFileName: String;
  public
    constructor Create(const APluginManger: TPluginManager; const AFileName: String); virtual;
    destructor Destroy; override;
  end;
 
//________________________________________________________________
 
var
  FPluginManager: IPluginManager;
 
function Plugins: IPluginManager;
begin
  Result := FPluginManager;
end;
 
{ TPluginManager }

function TPluginManager.GetCount: Integer;
begin
  Result := FCount;
end;

function TPluginManager.GetItem(const AIndex: Integer): IPlugin;
begin
  Result := FItems[AIndex];
end;

function TPluginManager.IndexOf(const APlugin: IPlugin): Integer;
var
  X: Integer;
begin
  Result := -1;
  for X := 0 to FCount - 1 do
    if FItems[X] = APlugin then
    begin
      Result := X;
      Break;
    end;
end;

function TPluginManager.LoadPlugin(const AFileName: String): IPlugin;
begin
  // Загружаем плагин
  Result := TPlugin.Create(self, AFileName);
 
  // Заносим в список
  if Length(FItems) <= FCount then // "Capacity"
    SetLength(FItems, Length(FItems) + 64);
  FItems[FCount] := Result;
  Inc(FCount);
end;

procedure TPluginManager.UnloadPlugin(const AIndex: Integer);
var
  X: Integer;
begin
  // Выгрузить плагин
  FItems[AIndex] := nil;
  // Сдвинуть плагины в списке, чтобы закрыть "дырку"
  for X := AIndex to FCount - 1 do
    FItems[X] := FItems[X + 1];
  // Не забыть учесть последний
  FItems[FCount - 1] := nil;
  Dec(FCount);
  //при выгрузке сдвигаются индексы !!!
end;

{ TPlugin }

constructor TPlugin.Create(const APluginManger: TPluginManager;
  const AFileName: String);
begin
  inherited Create;
  FManager := APluginManger;
  FFileName := AFileName;
  FHandle := SafeLoadLibrary(AFileName);
  Win32Check(FHandle <> 0);
end;

destructor TPlugin.Destroy;
begin
  if FHandle <> 0 then
  begin
    FreeLibrary(FHandle);
    FHandle := 0;
  end;
  inherited;
end;

function TPlugin.GetFileName: String;
begin
  Result := FFileName;
end;

function TPlugin.GetHandle: HMODULE;
begin
  Result := FHandle;
end;

function TPlugin.GetIndex: Integer;
begin
  Result := FManager.IndexOf(Self);
end;

initialization
  FPluginManager := TPluginManager.Create;
finalization
  FPluginManager := nil;
end.
