unit SDIMAIN;

interface

uses
  SysUtils,
  Classes,
  SynCommons,
  SynLog,
  mORMot,
  mORMotDB,
  mORMotHttpServer,
  SynDB,
  SynDBOracle,
  SynDBSQLite3, SynSQLite3Static,
  SynOleDB,
  SynDBODBC,
  Windows, Graphics, Forms, Controls, Menus,
  Dialogs, StdCtrls, Buttons, ExtCtrls, ComCtrls, ImgList, StdActns,
  ActnList, ToolWin, {$I SynDprUses.inc}  // use FastMM4 on older Delphi, or set FPC threads
  mORMotSQLite3,       // SQLite3 engine as ORM core
  uADStanIntf, uADPhysManager, uADPhysODBCBase, uADPhysMSSQL, SynDBFireDAC,           // external DB access via ODBC
  uModel, cxGraphics, cxLookAndFeels, cxLookAndFeelPainters, cxButtons,
  cxControls, cxContainer, cxEdit, cxTextEdit, cxMemo, Generics.Collections,
  uADPhysPG;           // data model unit, shared between server and client;

type
  TSDIAppForm = class(TForm)
    StatusBar: TStatusBar;
    pnlHeader: TPanel;
    lblPort: TLabel;
    edPORT: TcxTextEdit;
    btnStart: TcxButton;
    memLog: TcxMemo;
    edServer: TcxTextEdit;
    lblServer: TLabel;
    edUser: TcxTextEdit;
    lblUser: TLabel;
    edPassword: TcxTextEdit;
    lblPassword: TLabel;
    cbbEngine: TComboBox;
    lblEngine: TLabel;
    lblDatabase: TLabel;
    edDatabase: TcxTextEdit;
    adphyspgdrvrlnk1: TADPhysPgDriverLink;
    procedure btn1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FileNew1Execute(Sender: TObject);
    procedure btnStartClick(Sender: TObject);
  private
    { Private declarations }
  public
    function BacaRegistry(aNama : String ; aPath : String = ''): AnsiString;
    class function GetAppVersion: string;
    function TulisRegistry(aName, aValue: String; sAppName : String = ''): Boolean;
    { Public declarations }
  end;

var
  SDIAppForm: TSDIAppForm;
  Model: TSQLModel;
  Props: TSQLDBFireDACConnectionProperties;
  RestServer: TSQLRestServerDB;
  HttpServer: TSQLHttpServer;


implementation

uses about, uServerMethod, uISQLRemote, Registry;

{$R *.dfm}

function TSDIAppForm.BacaRegistry(aNama: String ; aPath : String = ''): AnsiString;
var
//  lobjectCOAs: TObjectList<TCOA>;
  Registry: TRegistry;
//  SQLTableJSON: TSQLTableJSON;
  //S: string;
begin
  Registry:=TRegistry.Create;
//  SQLTableJSON := TSQLTableJSON.Create('select * from coa');

//  lobjectCOAs := TObjectList<TCoa>.Create(True);
//  SQLTableJSON.ToObjectList(lobjectCOAs)

  Registry.RootKey := HKEY_CURRENT_USER;
  {False because we do not want to create it if it doesn’t exist}
  if Trim(RawUTF8(aPath)) = '' then
    Registry.OpenKey('\Software\' + Application.Title, False)
  else
    Registry.OpenKey('\Software\' + String(aPath), False);

  Result := AnsiString(Registry.ReadString(string(aNama)));

  Registry.Free;
end;

procedure TSDIAppForm.btn1Click(Sender: TObject);
var
  lUOM: TUOM;
begin
  lUOM := TUOM.Create;
  with lUOM do
  begin
    Kode := IntToString(GetTickCount);
    Nama := IntToString(GetTickCount);

    RestServer.TransactionBegin(TUOM);
    RestServer.Add(lUOM, True);
    RestServer.Commit();
  end;
end;

procedure TSDIAppForm.FormCreate(Sender: TObject);
begin
  Caption := Caption + ' Ver : ' + GetAppVersion;
  PTypeInfo(TypeInfo(TRemoteSQLEngine))^.EnumBaseType^.AddCaptionStrings(cbbEngine.Items);
  cbbEngine.ItemIndex := 0;

  if BacaRegistry('engine') <> '' then
    cbbEngine.ItemIndex := cbbEngine.Items.IndexOf(String(BacaRegistry(String('engine'))));

  edPORT.Text     := String(BacaRegistry('port'));
  edServer.Text   := String(BacaRegistry('server'));
  edUser.Text     := String(BacaRegistry('user'));
  edPassword.Text := String(BacaRegistry('password'));
  edDatabase.Text := String(BacaRegistry('database'));

//  cbbEngine.ItemIndex := cbbEngine.Items.IndexOf('PG');
//
//  edPORT.Text     := '5432';
//  edServer.Text   := 'localhost';
//  edUser.Text     := 'postgres';
//  edPassword.Text := '1234';
//  edDatabase.Text := 'ams';


end;

procedure TSDIAppForm.btnStartClick(Sender: TObject);
var
  sPortDB: string;
begin
  if btnStart.Caption = 'Stop' then
  begin
    HttpServer.Free;
    RestServer.Free;
    Model.Free;
    Props.Free;
    btnStart.Font.Color := clRed;
    btnStart.Caption    := 'Start';
  end else begin
    sPortDB := '1433';
    if cbbEngine.Text = 'PG' then
      sPortDB := '5432'
    else if cbbEngine.Text = 'MYSQL' then
      sPortDB := '3066';

    SQLite3Log.Family.Level := LOG_VERBOSE;
    SQLite3Log.Family.PerThreadLog := ptIdentifiedInOnFile;
    Props := TSQLDBFireDACConnectionProperties.Create(RawUTF8(cbbEngine.Text) + '?Server=' + RawUTF8(edServer.Text) + ' ;Port=' + RawUTF8(sPortDB), RawUTF8(edDatabase.Text),RawUTF8(edUser.Text), RawUTF8(edPassword.Text));
//    Props := TSQLDBFireDACConnectionProperties.Create('PG?Server=localhost;Port=5432','ams','postgres','1234');
//    Props := TSQLDBFireDACConnectionProperties.Create(RawUTF8(cbbEngine.Text) + '?Server= '+ RawUTF8(edServer.Text) + ';Port=5432','eponpes','postgres','1234');
    Props.StoreVoidStringAsNull := False;
    try
      // get the shared data model
      Model := TModel.DataModel;

      // use PostgreSQL database for all tables
      VirtualTableExternalRegisterAll(Model,Props);
      try
        // create the main mORMot server
        RestServer := TSQLRestServerDB.Create(Model,':memory:',false); // authentication=false
        try
          RestServer.ServiceRegister(TServiceRemoteSQL,[TypeInfo(IRemoteSQL)],sicClientDriven);
          // optionally execute all PostgreSQL requests in a single thread
          RestServer.AcquireExecutionMode[execORMGet]   := amBackgroundORMSharedThread;
          RestServer.AcquireExecutionMode[execORMWrite] := amBackgroundORMSharedThread;
          // create tables or fields if missing
          RestServer.CreateMissingTables;
          // serve aRestServer data over HTTP
          HttpServer := TSQLHttpServer.Create(AnsiString(edPORT.Text),[RestServer],'+',useHttpApiRegisteringURI);
//          HttpServer.cli
          try
            HttpServer.AccessControlAllowOrigin := '*'; // allow cross-site AJAX queries
            btnStart.Font.Color := clGreen;
            btnStart.Caption    := 'Stop';
          finally
          end;
        finally
        end;
      finally
      end;

      TulisRegistry('engine', cbbEngine.Text);
      TulisRegistry('server', edServer.Text);
      TulisRegistry('database', edDatabase.Text);
      TulisRegistry('user', edUser.Text);
      TulisRegistry('password', edPassword.Text);
      TulisRegistry('port', edPORT.Text);

    except
      on E : EXCEPTION do
      begin
        ShowMessage('Gagal Membangun Koneksi Dengan Pesan ' + E.Message);
      end;
    end;
  end;
end;

procedure TSDIAppForm.FileNew1Execute(Sender: TObject);
begin
  { Do nothing }
end;

class function TSDIAppForm.GetAppVersion: string;
var
  Size, Size2: DWord;
  Pt, Pt2: Pointer;
begin
 Size := GetFileVersionInfoSize(PChar (ParamStr(0)), Size2);
 if Size > 0 then
 begin
   GetMem (Pt, Size);
   try
      GetFileVersionInfo (PChar (ParamStr (0)), 0, Size, Pt);
      VerQueryValue (Pt, '\', Pt2, Size2);
      with TVSFixedFileInfo (Pt2^) do
      begin
        Result:= ' Ver '+
                 IntToStr (HiWord (dwFileVersionMS)) + '.' +
                 IntToStr (LoWord (dwFileVersionMS)) + '.' +
                 IntToStr (HiWord (dwFileVersionLS)) + '.' +
                 IntToStr (LoWord (dwFileVersionLS));
     end;
   finally
     FreeMem (Pt);
   end;
 end;
end;

function TSDIAppForm.TulisRegistry(aName, aValue: String; sAppName : String =
    ''): Boolean;
var
   Reg : TRegistry;
begin
    result := true;
    Reg := TRegistry.Create;
    try
      Reg.RootKey := HKEY_CURRENT_USER;
      if sAppName = '' then
      begin
        if Reg.OpenKey('\Software\' + Application.Title, True) then
        begin
             Reg.WriteString(aName, aValue);
             Reg.CloseKey;
        end
      end else begin
        if Reg.OpenKey('\Software\' + sAppName, True) then
        begin
             Reg.WriteString(aName, aValue);
             Reg.CloseKey;
        end;
      end;
    Except
      result := false;
      Reg.Free;
      exit;
    end;
   Reg.Free;
end;

end.
