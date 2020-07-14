unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls;

type
  TForm1 = class(TForm)
    ListBox1: TListBox;
    Button1: TButton;
    Edit1: TEdit;
    procedure Button1Click(Sender: TObject);
  private
    { Private declarations }
    procedure UpdatePluginsList;
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}
uses PluginManager;
{ TForm1 }

procedure TForm1.Button1Click(Sender: TObject);
begin
  Plugins.LoadPlugin(Edit1.Text);
  UpdatePluginsList;
end;

procedure TForm1.UpdatePluginsList;
var
  X: Integer;
begin
  ListBox1.Items.BeginUpdate;
  try
    ListBox1.Items.Clear;
    for X := 0 to Plugins.Count - 1 do
      ListBox1.Items.Add(IntToStr(Plugins[X].Index) + ': ' + Plugins[X].FileName);
  finally
    ListBox1.Items.EndUpdate;
  end;

end;

end.
