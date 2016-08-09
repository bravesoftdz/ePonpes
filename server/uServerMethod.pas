unit uServerMethod;

interface
uses
  uISQLRemote, SynCommons, mORMot, SDIMAIN, Classes, SysUtils, SynDB, uModel;

type

  TServiceRemoteSQL = class(TInterfacedObject, IRemoteSQL)
  protected
  public
    destructor Destroy; override;
  public
    function Execute(const aSQL: RawUTF8; aExpectResults, aExpanded: Boolean): RawJSON;
    function GenerateAIN(ACompanyID : Integer; ACatagoryID : Integer; ATglPerolehan
        : TDateTime; AKodeAkuisisi : String): String;
  end;

implementation

destructor TServiceRemoteSQL.Destroy;
begin
  inherited;
end;

function TServiceRemoteSQL.Execute(const aSQL: RawUTF8; aExpectResults,
    aExpanded: Boolean): RawJSON;
var
  res: ISQLDBRows;
begin
  if Props=nil then
    raise Exception.Create('Connect call required before Execute');

  res := Props.ExecuteInlined(aSQL,aExpectResults);
  if res = nil then
    result := ''
  else
    result := res.FetchAllAsJSON(aExpanded);
end;

function TServiceRemoteSQL.GenerateAIN(ACompanyID : Integer; ACatagoryID :
    Integer; ATglPerolehan : TDateTime; AKodeAkuisisi : String): String;
var
  sNomor: string;
  sSQL: string;
begin
  Result := '';
  with TCompany.Create(RestServer, ACompanyID) do
  begin
    try
      Result := Result + Kode;
    finally
      Free;
    end;
  end;

  with TAssetCategory.Create(RestServer, ACatagoryID) do
  begin
    try
      Result := Result + '.' + Kode;
    finally
      Free;
    end;
  end;

  Result := Result + '.' + FormatDateTime('YYYYMM', ATglPerolehan);
  Result := Result + '.' + AKodeAkuisisi;

  sNomor := '01';
  sSQL := 'select max(AIN) as No from Asset where ain like ' + QuotedStr(Result + '%');
  with Props.ExecuteInlined(sSQL,True) do
  begin
    while not Props.ExecuteInlined(sSQL,True).Step do
    begin
      sNomor := ColumnVariant(1);
      sNomor := StringReplace(sNomor, Result, '', [rfReplaceAll]);
      sNomor := IntToStr(StrToIntDef(sNomor,0) + 1);
    end;
  end;

  Result := Result + '.' + sNomor;
end;


end.

