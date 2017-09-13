//Created by: bit Time Professionals [https://github.com/bittimeprofessionals]
//Modified by DCE-Systems [https://github.com/dce-systems]

unit UModel;

interface

uses
  System.SysUtils, Validators.Attributes, Validators.Engine;

type
  TPerson = class
  private
    FEmail: string;
    FLastname: string;
    FFirstname: string;
    FAddress: string;
    FPwd: string;
    procedure SetEmail(const Value: string);
    procedure SetFirstname(const Value: string);
    procedure SetLastname(const Value: string);
    procedure SetAddress(const Value: string);
    procedure SetPwd(const Value: string);
  public
    constructor Create(aFirstname, aLastname, aEmail: string; aPwd: string = ''); overload;
    [RequiredValidation('AttributesValidation', 'Firstname is required')]
    [MaxLengthValidation('AttributesValidation', 'Firstname is too long', 8)]
    [MinLengthValidation('AttributesValidation', 'Firstname is too short', 4)]
    property Firstname: string read FFirstname write SetFirstname;
    [RequiredValidation('AttributesValidation', 'Firstname is required')]
    property Lastname: string read FLastname write SetLastname;
    [RequiredValidation('AttributesValidation', 'Firstname is required')]
    [EmailValidation('AttributesValidation', 'Email wrong')]
    property Email: string read FEmail write SetEmail;
    property Address: string read FAddress write SetAddress;
    [RegexValidation('AttributesValidation', 'Password not valid', '^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[$@$!%*?&])[A-Za-z\d$@$!%*?&]{8,}')]
    property Pwd: string read FPwd write SetPwd;
  end;

  TPersonValidator = class(TInterfacedObject, IValidator<TPerson>)
  public
    function Validate(aEntity: TPerson): IValidationResult;
  end;

implementation

constructor TPerson.Create(aFirstname, aLastname, aEmail, aPwd: string);
begin
  inherited Create;
  FFirstname := aFirstname;
  FLastname := aLastname;
  FEmail := aEmail;
  FPwd := aPwd;
end;

procedure TPerson.SetAddress(const Value: string);
begin
  FAddress := Value;
end;

procedure TPerson.SetEmail(const Value: string);
begin
  FEmail := Value;
end;

procedure TPerson.SetFirstname(const Value: string);
begin
  FFirstname := Value;
end;

procedure TPerson.SetLastname(const Value: string);
begin
  FLastname := Value;
end;

procedure TPerson.SetPwd(const Value: string);
begin
  FPwd := Value;
end;

{ TPersonLoginValidator<TPerson> }

function TPersonValidator.Validate(aEntity: TPerson): IValidationResult;
var
  lIsValid: boolean;
begin
  Result := TValidationResult.Create;

  if aEntity.Firstname.IsEmpty then
    Result.AddBrokenField('Firstname', ['Firstname is mandatory.']);
  if aEntity.Lastname.IsEmpty then
    Result.AddBrokenField('Lastname', ['Lastname is mandatory.']);
  if aEntity.Email.IsEmpty then
    Result.AddBrokenField('Email', ['Email is mandatory.']);
  if aEntity.Pwd.IsEmpty then
    Result.AddBrokenField('Pwd', ['Pwd is mandatory.']);

  lIsValid := not (aEntity.Firstname.IsEmpty or aEntity.Lastname.IsEmpty or aEntity.Email.IsEmpty);
  if not lIsValid then
    Result.BrokenRules := ['The fields Firstname, Lastname and Email are mandatory.'];
end;

end.
