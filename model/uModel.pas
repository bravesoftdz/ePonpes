unit uModel;

interface
uses
  mORMot, mORMotDB, SynCommons,  Contnrs;
type
  TModel = class(TSQLRecord)
    public
      class function DataModel: TSQLModel;
  end;

  TAssetCategory = class;

  TAssetType = class(TModel)
  private
    FKode: String;
    FNama: String;
  protected

  published
    property Kode: String read FKode write FKode;
    property Nama: String read FNama write FNama;
  end;

  TAssetStatus = class(TModel)
  private
    FKode: String;
    FNama: String;
  protected

  published
    property Kode: String read FKode write FKode;
    property Nama: String read FNama write FNama;
  end;

  TRefAssetOwnership = class(TModel)
  private
    FKode: string;
    FNama: string;
  published
    property Kode: string read FKode write FKode;
    property Nama: string read FNama write FNama;
  end;

  TDepreciationMethod = class(TModel)
  private
    FDescription: string;
    FFormula: string;
    FKode: String;
    FNama: String;
  protected

  published
    property Description: string read FDescription write FDescription;
    property Formula: string read FFormula write FFormula;
    property Kode: String index 10 read FKode write FKode;
    property Nama: String read FNama write FNama;
  end;

  TCompany = class(TModel)
  private
    FKode: String;
    FNama: String;
  protected

  published
    property Kode: String index 10 read FKode write FKode;
    property Nama: String read FNama write FNama;
  end;

  TEmployee = class(TModel)
  private
    FKode: String;
    FNama: String;
  protected

  published
    property Kode: String index 10 read FKode write FKode;
    property Nama: String read FNama write FNama;
  end;

  TEntity = class(TModel)
  private
    FKode: String;
    FNama: String;
  protected

  published
    property Kode: String index 10 read FKode write FKode;
    property Nama: String read FNama write FNama;
  end;

  TCurrency = class(TModel)
  private
    FKode: String;
    FNama: String;
  protected

  published
    property Kode: String index 10 read FKode write FKode;
    property Nama: String read FNama write FNama;
  end;

  TClassificationAsset = class(TModel)
  private
    FDefaultUsefulLifeMonth: Integer;
    FKode: String;
    FNama: String;
  protected

  published
    property DefaultUsefulLifeMonth: Integer read FDefaultUsefulLifeMonth write
        FDefaultUsefulLifeMonth;
    property Kode: String index 10 read FKode write FKode;
    property Nama: String read FNama write FNama;
  end;

  TUOM = class(TModel)
  private
    FKode: String;
    FNama: String;
  protected

  published
    property Kode: String index 10 read FKode write FKode;
    property Nama: String read FNama write FNama;
  end;

  TAssetProperty = class(TModel)
  private
    FDefaultValue: String;
    FDescription: String;
    FKode: String;
    FNama: String;
    FUOM: TUOM;
  protected
  public
  published
    property DefaultValue: String read FDefaultValue write FDefaultValue;
    property Description: String read FDescription write FDescription;
    property Kode: String index 10 read FKode write FKode;
    property Nama: String read FNama write FNama;
    property UOM: TUOM read FUOM write FUOM;
  end;

  TProjects = class(TModel)
  private
    FKode: String;
    FNama: String;
  protected

  published
    property Kode: String read FKode write FKode;
    property Nama: String read FNama write FNama;
  end;

  TCoa = class(TModel)
  private
    FKode: String;
    FNama: String;
  protected

  published
    property Kode: String read FKode write FKode;
    property Nama: String read FNama write FNama;
  end;

  TAssetConfigRole = class(TModel)
  private
    FAccountAccDep: TAssetConfigRole;
    FAccountCIP: TAssetConfigRole;
    FAccountDepExpense: TAssetConfigRole;
    FAccountDisposal: TCoa;
    FAccountRevaluationMin: TAssetConfigRole;
    FAssetType: TAssetType;
    FClassification: TClassificationAsset;
    FCurrency: TCurrency;
    FDepreciationMethod: TDepreciationMethod;
    FDescription: string;
    FEntity: TEntity;
    FKode: String;
    FNama: String;
    FOwnership: TRefAssetOwnership;
    FStatus: TAssetStatus;
    FAccountRevaluationPlus: TAssetConfigRole;
  protected
  published
    property Status: TAssetStatus read FStatus write FStatus;
    property AccountAccDep: TAssetConfigRole read FAccountAccDep write
        FAccountAccDep;
    property AccountCIP: TAssetConfigRole read FAccountCIP write FAccountCIP;
    property AccountDepExpense: TAssetConfigRole read FAccountDepExpense write
        FAccountDepExpense;
    property AccountDisposal: TCoa read FAccountDisposal write FAccountDisposal;
    property AccountRevaluationMin: TAssetConfigRole read FAccountRevaluationMin
        write FAccountRevaluationMin;
    property AssetType: TAssetType read FAssetType write FAssetType;
    property Classification: TClassificationAsset read FClassification write
        FClassification;
    property Currency: TCurrency read FCurrency write FCurrency;
    property DepreciationMethod: TDepreciationMethod read FDepreciationMethod write
        FDepreciationMethod;
    property Description: string read FDescription write FDescription;
    property Entity: TEntity read FEntity write FEntity;
    property Kode: String index 10 read FKode write FKode stored AS_UNIQUE;
    property Nama: String read FNama write FNama;
    property Ownership: TRefAssetOwnership read FOwnership write FOwnership;
    property AccountRevaluationPlus: TAssetConfigRole read FAccountRevaluationPlus
        write FAccountRevaluationPlus;
  end;

  TAsset = class(TModel)
  private
    FAccountAccDep: TCoa;
    FAccountAssetAP: TCoa;
    FAIN: String;
    FAssetStatus: TAssetStatus;
    FAssetType: TAssetType;
    FCategory: TAssetCategory;
    FCompany: TCompany;
    FDateCreated: TDateTime;
    FNama: String;
  protected
  published
    property AccountAccDep: TCoa read FAccountAccDep write FAccountAccDep;
    property Category: TAssetCategory read FCategory write FCategory;
    property Company: TCompany read FCompany write FCompany;
    property DateCreated: TDateTime read FDateCreated write FDateCreated;
    property AIN: String index 20 read FAIN write FAIN stored AS_UNIQUE;
    property AssetStatus: TAssetStatus read FAssetStatus write FAssetStatus;
    property AssetType: TAssetType read FAssetType write FAssetType;
    property Nama: String read FNama write FNama;
    property AccountAssetAP: TCoa read FAccountAssetAP write FAccountAssetAP;
  end;

  TAssetCategory = class(TModel)
  private
    FAccountFixedActiva: TCoa;
    FConfigDefault: TAssetConfigRole;
    FDescription: string;
    FKode: string;
    FCatLevel: Integer;
    FNama: string;
    FParent: TAssetCategory;
  published
    property AccountFixedActiva: TCoa read FAccountFixedActiva write
        FAccountFixedActiva;
    property ConfigDefault: TAssetConfigRole read FConfigDefault write
        FConfigDefault;
    property Description: string read FDescription write FDescription;
    property Kode: string index 10 read FKode write FKode stored AS_UNIQUE;
    property CatLevel: Integer read FCatLevel write FCatLevel;
    property Nama: string read FNama write FNama;
    property Parent: TAssetCategory read FParent write FParent;
  end;

  TAssetCategoryClient = class(TAssetCategory)
  private
    FAssetCategoryChilds: TObjectList;
    function GetAssetCategoryChilds: TObjectList;
  published
    property AssetCategoryChilds: TObjectList read GetAssetCategoryChilds write
        FAssetCategoryChilds;
  end;

implementation

class function TModel.DataModel: TSQLModel;
begin
  result := TSQLModel.Create([TAsset, TCoa, TUOM, TAssetProperty,
                              TDepreciationMethod, TCurrency,
                              TClassificationAsset, TCompany,
                              TEntity,
                              TEmployee,
                              TProjects,
                              TRefAssetOwnership,
                              TAssetConfigRole,
                              TAssetType,
                              TAssetStatus,
                              TAssetCategory],'root');
//  TAsset.AddFilterOrValidate('Kode',TSynValidateText.Create); // ensure exists
//  TCoa.AddFilterOrValidate('Kode',TSynValidateText.Create); // ensure exists
//  TUOM.AddFilterOrValidate('Kode',TSynValidateText.Create); // ensure exists
//  TAssetProperty.AddFilterOrValidate('Kode',TSynValidateText.Create); // ensure exists
//  TDepreciationMethod.AddFilterOrValidate('Kode',TSynValidateText.Create); // ensure exists
end;

function TAssetCategoryClient.GetAssetCategoryChilds: TObjectList;
var
  lSQLTable: TSQLTableJSON;
  sSQL: RawUTF8;
begin
  if FAssetCategoryChilds = nil then
  begin
    FAssetCategoryChilds := TObjectList.Create;
    sSQL := 'select * from AssetCategory where id = ' + RawUTF8(IntToString(Self.ID));

    lSQLTable := TSQLTableJSON.CreateFromTables([TAssetCategoryClient], sSQL);
    lSQLTable.ToObjectList(FAssetCategoryChilds, TAssetCategoryClient);
  end;

  Result := FAssetCategoryChilds;
end;



end.
