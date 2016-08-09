unit uISQLRemote;

interface
uses SynCommons,mORMot, uModel;


type
  TRemoteSQLEngine = (rseMSSQL, rseIB, rseFB, rseMYSQL, rseOleDB, rseODBC, rseOracle, rseSQlite3, rseJet, rsePG);

  IRemoteSQL = interface(IInvokable)
  ['{0E34DC10-0A32-4A19-97E4-8012E06D32AA}']
    function Execute(const aSQL: RawUTF8; aExpectResults, aExpanded: Boolean): RawJSON;
    function GenerateAIN(ACompanyID : Integer; ACatagoryID : Integer; ATglPerolehan : TDateTime; AKodeAkuisisi : String) : String;
//    function GetCOA(AID : Integer): RawJSON;
  end;

implementation

end.
