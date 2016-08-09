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
    function Execute(const aSQL: RawUTF8; aExpectResults, aExpanded: Boolean):
        RawJSON;
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


end.

