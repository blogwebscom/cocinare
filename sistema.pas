unit sistema;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, JLabeledFloatEdit, ZDataset, Forms, Controls,
  Graphics, Dialogs, ExtCtrls, StdCtrls, Buttons, sqlite3backup, sqlite3conn;

type

  { Tf_sis }

  Tf_sis = class(TForm)
    b_bk: TButton;
    b_vacia: TButton;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label6: TLabel;
    pdb: TJLabeledFloatEdit;
    Shape2: TShape;
    Shape3: TShape;
    sqlite3bk: TSQLite3Connection;
    vok: TLabel;
    ck_rec: TCheckBox;
    Shape1: TShape;
    ck_cat: TCheckBox;
    qexe: TZQuery;
    procedure b_bkClick(Sender: TObject);
    procedure b_vaciaClick(Sender: TObject);
  private
    { private declarations }
  public
    { public declarations }
  end;

var
  f_sis: Tf_sis;

implementation

{$R *.lfm}

{ Tf_sis }

procedure Tf_sis.b_vaciaClick(Sender: TObject);
begin
  //*Pregunta de Seguridad?
  if MessageDlg('ATENCION!!','Está seguro que desea VACIAR las Tablas seleccionadas'+#13+
  'Este proceso es Irreversible.',mtConfirmation,[mbYes, mbNo],0) = mrYes then
  begin
    if (ck_rec.Checked) OR (ck_cat.Checked) then
    begin
      if ck_rec.Checked then                  // RECETAS
      begin
        qexe.Active:= false;
        qexe.SQL.Text:= 'DELETE FROM recetas';
        qexe.ExecSQL;
        qexe.Active:= false;
        qexe.SQL.Text:= 'DELETE FROM SQLITE_SEQUENCE WHERE name=''recetas''';
        qexe.ExecSQL;
      end;
      if ck_cat.Checked then                  // CATEGORIAS
      begin
        qexe.Active:= false;
        qexe.SQL.Text:= 'DELETE FROM categorias';
        qexe.ExecSQL;
        qexe.Active:= false;
        qexe.SQL.Text:= 'DELETE FROM SQLITE_SEQUENCE WHERE name=''categorias''';
        qexe.ExecSQL;
      end;
      vok.Caption:= 'OK!';
    end;
  end;
end;

procedure Tf_sis.b_bkClick(Sender: TObject);
var
  BKFolder: string;
  bk: TSQLite3Backup;
begin
  {Configuración}
  BKFolder:= ExtractFileDir(Application.ExeName)+'\DB\';
  sqlite3bk.DatabaseName:= BKFolder+'rec_data.db'; // conecta con la base de datos
  sqlite3bk.Open;
  if sqlite3bk.Connected then
  begin
    bk:= TSQLite3Backup.Create;
    try
      bk.Backup(sqlite3bk,BKFolder+'BK_'+FormatDateTime('yyyyMMDD_HHmm',Now)+'.db', False);
      MessageDlg('Aviso','Copia de Seguridad creada correctamente!'+#13+
      'Se encuentra en la carpeta "DB" del programa.',mtInformation,[mbOK],0);
    finally
      bk.Free;
    end;
  end else
    MessageDlg('ATENCION!','ERROR: No se pudo realizar el respaldo...'+#13+
    'Contacte con el soporte técnico: webscom.ar@gmail.com',mtError,[mbOK],0);
end;

end.

