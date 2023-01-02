unit categorias;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, db, FileUtil, JLabeledIntegerEdit, ZDataset, Forms,
  Controls, Graphics, Dialogs, DBGrids, StdCtrls, Buttons, ExtCtrls;

type

  { Tf_cates }

  Tf_cates = class(TForm)
    b_del: TBitBtn;
    b_nva: TBitBtn;
    b_mod: TBitBtn;
    b_graba: TBitBtn;
    datos: TDatasource;
    idc: TJLabeledIntegerEdit;
    Label1: TLabel;
    can: TLabel;
    cnom: TLabeledEdit;
    lista: TDBGrid;
    qlista: TZQuery;
    qexe: TZQuery;
    xcod: TRadioButton;
    xnom: TRadioButton;
    Shape2: TShape;
    procedure b_delClick(Sender: TObject);
    procedure b_grabaClick(Sender: TObject);
    procedure b_modClick(Sender: TObject);
    procedure b_nvaClick(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure xcodChange(Sender: TObject);
    procedure xnomChange(Sender: TObject);
  private
    { private declarations }
    procedure listar();
  public
    { public declarations }
  end;

var
  f_cates: Tf_cates;
  oper: char;

implementation

{$R *.lfm}

{ Tf_cates }

procedure Tf_cates.FormActivate(Sender: TObject);
begin
  listar();
end;

procedure Tf_cates.xcodChange(Sender: TObject);
begin
  listar();
end;

procedure Tf_cates.xnomChange(Sender: TObject);
begin
  listar();
end;

procedure Tf_cates.listar();
begin
  qlista.Active:= false;
  if xcod.Checked then
    qlista.SQL.Text:= 'SELECT * FROM categorias ORDER BY id_cat ASC'
  else
    qlista.SQL.Text:= 'SELECT * FROM categorias ORDER BY cnom ASC';
  qlista.Open;
  can.Caption:= inttostr(qlista.RecordCount);
end;

procedure Tf_cates.b_nvaClick(Sender: TObject);
begin
  cnom.ReadOnly:= false; cnom.Clear;
  idc.ReadOnly:= false; idc.SetFocus;
  b_nva.Enabled:= false; b_mod.Enabled:= false;
  b_del.Enabled:= false; b_graba.Enabled:= true;
  oper:= 'A';
end;

procedure Tf_cates.b_modClick(Sender: TObject);
begin
  idc.Value:= qlista.FieldByName('id_cat').Value;
  cnom.Text:= qlista.FieldByName('cnom').Text;
  cnom.ReadOnly:= false; {idc.ReadOnly:= false;}
  b_nva.Enabled:= false; b_mod.Enabled:= false;
  b_del.Enabled:= false; b_graba.Enabled:= true;
  cnom.SetFocus; oper:= 'M';
end;

procedure Tf_cates.b_grabaClick(Sender: TObject);
begin
  if idc.Value <> 0 then
  begin
    if cnom.Text <> '' then
    begin
      qexe.Active:= false;
      if oper = 'A' then {----------- Nueva}
        qexe.SQL.Text:= 'INSERT INTO categorias(id_cat,cnom) VALUES(:ID,:CN)'
      else               {----------- Modifica}
        qexe.SQL.Text:= 'UPDATE categorias SET cnom=:CN WHERE id_cat=:ID';
      {Parametros}
      qexe.ParamByName('ID').AsInteger:= idc.Value;
      qexe.ParamByName('CN').AsString:= uppercase(trim(cnom.Text));
      qexe.ExecSQL;
      // OK ...
      listar();
      qlista.Locate('id_cat',idc.Value,[]);
      {Limpieza y Deshab.}
      cnom.Clear; cnom.ReadOnly:= true;
      idc.Value:= 0; idc.ReadOnly:= true;
      b_nva.Enabled:= true; b_mod.Enabled:= true;
      b_del.Enabled:= true; b_graba.Enabled:= false;
    end else begin
      showmessage('Indique el Nombre de la Categoría!');
      cnom.SetFocus;
    end;
  end else begin
    showmessage('Indique el ID del Sistema.');
    idc.SetFocus;
  end;
end;

procedure Tf_cates.b_delClick(Sender: TObject);
begin
  //*Pregunta de Seguridad?
  if MessageDlg('ATENCION!!','Está seguro que desea ELIMINAR esta Categoría:'+#13#13
  +qlista.FieldByName('cnom').Text+#13#13+
  'Las Recetas que pertenecen a esta categoría pasarán a "Otras"'+#13+
  'Este proceso es irreversible!', mtConfirmation,[mbYes, mbNo],0) = mrYes then
  begin
    // Paso los productos a General
    qexe.Active:= false;
    qexe.SQL.Text:= 'UPDATE recetas SET id_cat=42 WHERE id_cat=:IC';
    qexe.ParamByName('IC').AsInteger:= qlista.FieldByName('id_cat').Value;
    qexe.ExecSQL;
    // Elimino la Categoria
    qexe.Active:= false;
    qexe.SQL.Text:= 'DELETE FROM categorias WHERE id_cat=:IC';
    qexe.ParamByName('IC').AsInteger:= qlista.FieldByName('id_cat').Value;
    qexe.ExecSQL;
    listar();
  end;
end;

end.

