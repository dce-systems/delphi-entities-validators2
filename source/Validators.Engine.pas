//Created by: bit Time Professionals [https://github.com/bittimeprofessionals]
//Modified by DCE-Systems [https://github.com/dce-systems]
//
//Changes:
//        1) BrokenRules can be returned as String.
//        2) Form component can be bind to property.
//        3) Form component can be highlight when binded property is invalid.
//        4) Highlight color can be modify from runtime.
//        5) Form component can show hint with invalid rules list.

unit Validators.Engine;

interface

uses
  System.RTTI, System.JSON, System.Generics.Collections, System.Classes, Vcl.StdCtrls,
  Vcl.Graphics, Vcl.Controls;

type
  TBrokenRules = array of string;

  TBrokenFields = TDictionary<string, TBrokenRules>;

  TBrokenObjects = TDictionary<string, TObject>;

  TBrokenRulesHelper = record helper for TBrokenRules
  public
    function asJsonArray: TJSONArray;
  end;

  IValidationResult = interface
    ['{14B7A1EF-DCD0-416C-BAF1-CF25A6F6E202}']
    function GetBrokenRules: TBrokenRules;
    function GetBrokenRulesText: string;
    function GetBrokenFields: TBrokenFields;
    function GetBrokenObjects: TBrokenObjects;
    function GetValidationColor: TColor;
    procedure SetBrokenRules(aBrokenRules: TBrokenRules);
    procedure SetValidationColor(AValidationColor: TColor);
    procedure AddBrokenRules(aBrokenRules: TBrokenRules);
    procedure AddBrokenField(aBrokenField: string; aBrokenRules: TBrokenRules);
    property BrokenRules: TBrokenRules read GetBrokenRules write SetBrokenRules;
    property BrokenRulesText: string read GetBrokenRulesText;
    property BrokenFields: TBrokenFields read GetBrokenFields;
    property BrokenObjects: TBrokenObjects read GetBrokenObjects;
    property ValidationColor: TColor read GetValidationColor write SetValidationColor;
    function IsValid(const aRaiseExceptionIfNot: boolean = False; AHighlightInvalidComponents: Boolean = True): boolean;
    procedure Bind(const AProperty: string; const AComponentName: TObject);
    procedure HighlightInvalidComponents(AClearText: Boolean = False);
  end;

  TValidationResult = class(TInterfacedObject, IValidationResult)
  private
    FValidationColor: TColor;
    procedure SetHighlight(const AObject: TObject; AColor: TColor; AClearText: Boolean);
    procedure SetHint(const AObject: TObject; ABrokenRules: TBrokenRules);
  protected
    FBrokenRules: TBrokenRules;
    FBrokenFields: TBrokenFields;
    FBrokenObjects: TBrokenObjects;
  public
    constructor Create;
    destructor Destroy; override;
    function GetBrokenRules: TBrokenRules;
    function GetBrokenRulesText: string;
    function GetBrokenFields: TBrokenFields;
    function GetBrokenObjects: TBrokenObjects;
    function GetValidationColor: TColor;
    procedure SetBrokenRules(aBrokenRules: TBrokenRules);
    procedure SetValidationColor(AValidationColor: TColor);
    procedure AddBrokenRules(aBrokenRules: TBrokenRules);
    procedure AddBrokenField(aBrokenField: string; aBrokenRules: TBrokenRules);
    property BrokenRules: TBrokenRules read GetBrokenRules write SetBrokenRules;
    property BrokenRulesText: string read GetBrokenRulesText;
    property BrokenFields: TBrokenFields read GetBrokenFields;
    property BrokenObjects: TBrokenObjects read GetBrokenObjects;
    property ValidationColor: TColor read GetValidationColor write SetValidationColor;
    function IsValid(const aRaiseExceptionIfNot: boolean = False; AHighlightInvalidComponents: Boolean = True): boolean;
    procedure Bind(const AProperty: string; const AComponentName: TObject);
    procedure HighlightInvalidComponents(AClearText: Boolean = False);
  end;

  IValidator<T> = interface
    ['{A81A5167-68BB-49D3-B2F8-BC0557FA240C}']
    function Validate(aEntity: T): IValidationResult;
  end;

  IValidatable<T> = interface
    ['{01643E54-2058-4C42-BD98-462EA78E1CAB}']
    function Validate(aValidator: IValidator<T>; out aBrokenRules: TBrokenRules): boolean;
  end;

  IValidatorContainer = interface
    ['{DCC0B831-822B-4159-B132-10587E8BFDFB}']
    procedure RegisterValidatorFor(aType: TClass; aContext: string);
    function GetValidatorFor(aType: TClass; aContext: string): IValidator<TClass>;
  end;

  TBaseValidatorContainer = class(TObject)
  private
    FRegistry: TDictionary<TClass, TDictionary<string, IInterface>>;
  public
    constructor Create;
    destructor Destroy; override;
    procedure RegisterValidatorFor<T: class>(aContext: string; aValidator: IValidator<T>);
    function GetValidatorFor<T: class>(aContext: string): IValidator<T>;
  end;

  TValidationEngine = class(TObject)
  private
    class var
      FRTTIContext: TRttiContext;
    class var
      FValidationContainer: TBaseValidatorContainer;
  public
    class constructor Create;
    class destructor Destroy;
    class function Validate<T: class>(aObject: T; aContext: string): IValidationResult;
    class function PropertyValidation(aObject: TObject; aContext: string): IValidationResult;
    class function EntityValidation<T: class>(aObject: T; aContext: string): IValidationResult;
    class property ValidationContainer: TBaseValidatorContainer read FValidationContainer;
  end;

implementation

uses
  Validators.Attributes, System.SysUtils;

{ TBrokenRulesHelper }

function TBrokenRulesHelper.asJsonArray: TJSONArray;
var
  I: Integer;
begin
  Result := TJSONArray.Create;
  for I := Low(self) to High(self) do
    Result.Add(self[I]);
end;

{ TRunTimeValidator }

class constructor TValidationEngine.Create;
begin
  FRTTIContext := TRttiContext.Create;
  FValidationContainer := TBaseValidatorContainer.Create;
end;

class destructor TValidationEngine.Destroy;
begin
  FRTTIContext.Free;
  FValidationContainer.Free;
end;

class function TValidationEngine.EntityValidation<T>(aObject: T; aContext: string): IValidationResult;
var
  a: TCustomAttribute;
  lValidator: IValidator<T>;
begin
  Result := TValidationResult.Create;
  lValidator := FValidationContainer.GetValidatorFor<T>(aContext);
  Result.AddBrokenRules(lValidator.Validate(aObject).BrokenRules);
end;

class function TValidationEngine.PropertyValidation(aObject: TObject; aContext: string): IValidationResult;
var
  rt: TRttiType;
  a: TCustomAttribute;
  p: TRttiProperty;
  m: TRttiMethod;
begin
  Result := TValidationResult.Create;
  rt := FRTTIContext.GetType(aObject.ClassType);
  for p in rt.GetProperties do
    for a in p.GetAttributes do
    begin
      if not (a is ValidationAttribute) then
        continue;
      if ValidationAttribute(a).Context <> aContext then
        continue;
      m := FRTTIContext.GetType(a.ClassType).GetMethod('Validate');
      if m = nil then
        continue;

      if Length(m.Invoke(a, [p.GetValue(aObject).AsString]).AsType < IValidationResult > .BrokenRules) > 0 then
        Result.AddBrokenField(p.Name, m.Invoke(a, [p.GetValue(aObject).AsString]).AsType < IValidationResult > .BrokenRules);

      Result.AddBrokenRules(m.Invoke(a, [p.GetValue(aObject).AsString]).AsType < IValidationResult > .BrokenRules);
    end;
end;

class function TValidationEngine.Validate<T>(aObject: T; aContext: string): IValidationResult;
var
  rt: TRttiType;
  cx: TRttiContext;
  a: TCustomAttribute;
  p: TRttiProperty;
  m: TRttiMethod;
  lValidator: IValidator<T>;
begin
  Result := TValidationResult.Create;
  Result.AddBrokenRules(EntityValidation<T>(aObject, aContext).BrokenRules);
  Result.AddBrokenRules(PropertyValidation(aObject, aContext).BrokenRules);
end;

{ TBaseValidatorContainer }

constructor TBaseValidatorContainer.Create;
begin
  FRegistry := TDictionary<TClass, TDictionary<string, IInterface>>.Create;
end;

destructor TBaseValidatorContainer.Destroy;
var
  lVal: TDictionary<string, IInterface>;
begin
  for lVal in FRegistry.Values do
    lVal.Free;
  FRegistry.Free;
  inherited;
end;

function TBaseValidatorContainer.GetValidatorFor<T>(aContext: string): IValidator<T>;
begin
  Result := FRegistry[T][aContext] as IValidator<T>;
end;

procedure TBaseValidatorContainer.RegisterValidatorFor<T>(aContext: string; aValidator: IValidator<T>);
var
  lDictionary: TDictionary<string, IInterface>;
begin
  if not FRegistry.TryGetValue(T, lDictionary) then
    lDictionary := TDictionary<string, IInterface>.Create();
  lDictionary.AddOrSetValue(aContext, aValidator);
  FRegistry.AddOrSetValue(T, lDictionary);
end;

{ TValidationResult }

procedure TValidationResult.AddBrokenRules(aBrokenRules: TBrokenRules);
begin
  FBrokenRules := FBrokenRules + aBrokenRules;
end;

procedure TValidationResult.AddBrokenField(aBrokenField: string; aBrokenRules: TBrokenRules);
var
  Temp: TBrokenRules;
begin
  if FBrokenFields.ContainsKey(aBrokenField) then
  begin
    Temp := FBrokenFields.Items[aBrokenField] + aBrokenRules;
    FBrokenFields.AddOrSetValue(aBrokenField, Temp);
  end
  else
    FBrokenFields.Add(aBrokenField, aBrokenRules);
end;

function TValidationResult.GetBrokenFields: TBrokenFields;
begin
  Result := FBrokenFields;
end;

function TValidationResult.GetBrokenObjects: TBrokenObjects;
begin
  Result := FBrokenObjects;
end;

function TValidationResult.GetBrokenRules: TBrokenRules;
begin
  Result := FBrokenRules;
end;

function TValidationResult.GetBrokenRulesText: string;
var
  Rule: string;
begin
  for Rule in FBrokenRules do
  begin
    Result := Trim(Result + #13#10 + Rule);
  end;
end;

function TValidationResult.GetValidationColor: TColor;
begin
  Result := FValidationColor;
end;

function TValidationResult.IsValid(const aRaiseExceptionIfNot: boolean = False; AHighlightInvalidComponents: Boolean = True): boolean;
begin
  Result := Length(FBrokenRules) <= 0;
  if not Result then
  begin
    if AHighlightInvalidComponents then
      HighlightInvalidComponents;

    if aRaiseExceptionIfNot then
      raise Exception.Create(FBrokenRules.asJsonArray.ToJSON);
  end;
end;

procedure TValidationResult.Bind(const AProperty: string; const AComponentName: TObject);
begin
  if FBrokenObjects.ContainsKey(AProperty) then
    FBrokenObjects.Remove(AProperty);

  FBrokenObjects.Add(AProperty, AComponentName);
  SetHighlight(AComponentName, clWindow, False);
end;

procedure TValidationResult.HighlightInvalidComponents(AClearText: Boolean = False);
var
  BrokenField: TPair<string, TBrokenRules>;
  BrokenObject: TPair<string, TObject>;
begin
  for BrokenField in FBrokenFields do
    if Length(BrokenField.Value) > 0 then
      for BrokenObject in FBrokenObjects do
        if BrokenField.Key = BrokenObject.Key then
          if Assigned(BrokenObject.Value) then
          begin
            SetHighlight(BrokenObject.Value, FValidationColor, AClearText);
            SetHint(BrokenObject.Value, BrokenField.Value);
          end;
end;

constructor TValidationResult.Create;
begin
  FBrokenFields := TDictionary<string, TBrokenRules>.Create();
  FBrokenObjects := TDictionary<string, TObject>.Create();

  FValidationColor := $8080F0; //Light Coral 	240-128-128
end;

destructor TValidationResult.Destroy;
begin
  FBrokenFields.Free;
  FBrokenObjects.Free;
  inherited;
end;

procedure TValidationResult.SetBrokenRules(aBrokenRules: TBrokenRules);
begin
  FBrokenRules := aBrokenRules;
end;

procedure TValidationResult.SetHighlight(const AObject: TObject; AColor: TColor; AClearText: Boolean);
var
  RTTIContext: TRttiContext;
  RttiType: TRttiType;
  RttiProperty: TRttiProperty;
begin
  if Assigned(AObject) then
  begin
    RttiType := RTTIContext.GetType(AObject.ClassType);
    if Assigned(RttiType) then
    begin
      RttiProperty := RttiType.GetProperty('Color');
      if Assigned(RttiProperty) then
        RttiProperty.SetValue(AObject, AColor);
      RttiProperty := RttiType.GetProperty('Text');
      if Assigned(RttiProperty) and AClearText then
        RttiProperty.SetValue(AObject, '');
    end;
  end;
end;

procedure TValidationResult.SetHint(const AObject: TObject; ABrokenRules: TBrokenRules);
var
  Rule, Hint: string;
begin
  if Assigned(AObject) then
  begin
    if AObject is TControl then
    begin
      for Rule in ABrokenRules do
        Hint := Hint + Rule + #13#10;
      (AObject as TControl).Hint := Trim(Hint);
      (AObject as TControl).ShowHint := Hint <> '';
    end;
  end;
end;

procedure TValidationResult.SetValidationColor(AValidationColor: TColor);
begin
  FValidationColor := AValidationColor;
end;

end.

