//Created by DCE-Systems [https://github.com/dce-systems]

unit UApp;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, System.Generics.Collections,
  UModel,
  Validators.Attributes,
  Validators.Engine;

type
  TAppForm = class(TForm)
    ButtonSimple: TButton;
    ButtonAttributes: TButton;
    EditFirstname: TEdit;
    LabelFirstname: TLabel;
    EditLastname: TEdit;
    LabelLastname: TLabel;
    EditEmail: TEdit;
    LabelEmail: TLabel;
    EditPwd: TEdit;
    LabelPwd: TLabel;
    procedure ButtonSimpleClick(Sender: TObject);
    procedure ButtonAttributesClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  AppForm: TAppForm;

implementation

{$R *.dfm}

procedure TAppForm.ButtonSimpleClick(Sender: TObject);
var
  Person: TPerson;
  PersonValidator: IValidator<TPerson>;
  ValidationResult: IValidationResult;
  Rule: string;
begin
  Person := TPerson.Create(EditFirstname.Text, EditLastname.Text, EditEmail.Text, EditPwd.Text);

  PersonValidator := TPersonValidator.Create;

  try
    ValidationResult := PersonValidator.Validate(Person);

    ValidationResult.Bind('Firstname', EditFirstname);
    ValidationResult.Bind('Lastname', EditLastname);
    ValidationResult.Bind('Email', EditEmail);
    ValidationResult.Bind('Pwd', EditPwd);
    
    ValidationResult.ValidationColor := clYellow; //Change color
    
    if not ValidationResult.IsValid then
      for Rule in ValidationResult.BrokenRules do  //Iteration by rule
        ShowMessage(Rule);
  finally
    Person.Free;
  end;
end;

procedure TAppForm.ButtonAttributesClick(Sender: TObject);
var
  Person: TPerson;
  ValidationResult: IValidationResult;
begin
  Person := TPerson.Create(EditFirstname.Text, EditLastname.Text, EditEmail.Text, EditPwd.Text);

  try
    ValidationResult := TValidationEngine.PropertyValidation(Person, 'AttributesValidation');

    ValidationResult.Bind('Firstname', EditFirstname);
    ValidationResult.Bind('Lastname', EditLastname);
    ValidationResult.Bind('Email', EditEmail);
    ValidationResult.Bind('Pwd', EditPwd);
    
    if not ValidationResult.IsValid then
      ShowMessage(ValidationResult.BrokenRulesText);  //Rule as String
  finally
    Person.Free;
  end;
end;

end.

