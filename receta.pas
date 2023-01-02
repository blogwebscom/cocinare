unit receta;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, db, FileUtil, LR_Class, lr_e_pdf, JLabeledIntegerEdit,
  JLabeledDateEdit, ZDataset, Forms, Controls, Graphics, Dialogs, ExtCtrls,
  StdCtrls, Buttons, ExtDlgs, DbCtrls, LResources;

type

  { Tf_rece }

  Tf_rece = class(TForm)
    b_imp: TBitBtn;
    b_save: TBitBtn;
    b_del: TBitBtn;
    b_mod: TBitBtn;
    b_nva: TBitBtn;
    dcates: TDataSource;
    ing2: TMemo;
    rpdfex: TfrTNPDFExport;
    repo: TfrReport;
    rfec: TJLabeledDateEdit;
    lcates: TDBLookupComboBox;
    idre: TJLabeledIntegerEdit;
    faviso: TLabel;
    Label4: TLabel;
    visto: TJLabeledIntegerEdit;
    locpic: TOpenPictureDialog;
    rfoto: TImage;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    rnom: TLabeledEdit;
    anom: TLabeledEdit;
    ing: TMemo;
    ins: TMemo;
    qexe: TZQuery;
    fondo: TShape;
    qcates: TZQuery;
    wqexe: TZQuery;
    procedure b_delClick(Sender: TObject);
    procedure b_impClick(Sender: TObject);
    procedure b_modClick(Sender: TObject);
    procedure b_nvaClick(Sender: TObject);
    procedure b_saveClick(Sender: TObject);
    procedure b_upClick(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure repoEnterRect({%H-}Memo: TStringList; View: TfrView);
    procedure repoGetValue(const ParName: String; var ParValue: Variant);
    procedure rfotoDblClick(Sender: TObject);
  private
    { private declarations }
    procedure habdes();
    procedure id_nva();
    procedure vacios();
  public
    { public declarations }
    procedure carga_cats();
    var
      op: char;
      imgname: string;
  end;

var
  f_rece: Tf_rece;
  OK: char;

implementation

uses
  main;

{$R *.lfm}

{ Tf_rece }

procedure Tf_rece.FormActivate(Sender: TObject);
begin
  // La carga de categorias se hace desde los 2 accesos en main
  // Variable publica que determina.
  if op = 'A' then
  begin
    habdes();
    id_nva();
  end;
end;

procedure Tf_rece.carga_cats();
begin
  // Carga categorías
  qcates.Active:= false;
  qcates.SQL.Text:= 'SELECT * FROM categorias ORDER BY cnom ASC';
  qcates.Open;
end;

procedure Tf_rece.id_nva();
begin
  // ID Nueva receta -----
  qexe.Active:= false;
  {qexe.SQL.Text:= 'REPLACE INTO sqlite_sequence (name,seq) VALUES (:TABLA,1006)'; //ACTUALIZA ID!}
  qexe.SQL.Text:= 'SELECT seq AS ULT FROM sqlite_sequence WHERE name=:TABLA';
  qexe.ParamByName('TABLA').AsString:= 'recetas';
  {try
    qexe.ExecSQL;
  except
    showmessage('NO');
  end;}
  qexe.Open;
  if qexe.FieldByName('ULT').Value = Null then idre.Value:= 1
  else idre.Value:= qexe.FieldByName('ULT').Value + 1;
  // Foto/Imagen resetada ----
  imgname:= 'sin-foto.jpg';
  rfoto.Picture.LoadFromFile(f_main.basepic+imgname);
end;

procedure Tf_rece.rfotoDblClick(Sender: TObject);
var
  imgpath, imgext: string;
begin
  //--Localiza un archivo de imagen--//
  if locpic.Execute then imgpath:= locpic.FileName; {Ruta completa}
  if imgpath <> '' then                             {Selecciona?}
  begin
    rfoto.Picture.LoadFromFile(imgpath);                               {Para Copiar nueva IMG cargo}
    imgname:= lowercase(ExtractFileName(imgpath));                     {Tomo solo nombre}
    imgname:= stringreplace(imgname,' ','_',[rfReplaceAll]);           {Configuro edito}
    imgext:= copy(imgname,pos('.',imgname),length(imgname));           {Para el cambio extension}
    imgname:= stringreplace(imgname,imgext,'.jpg',[rfIgnoreCase]);     {Cambia la extencion a JPG}
    imgpath:= f_main.basepic+imgname;                                  {Path para grabar+foto}
    rfoto.Picture.SaveToFile(imgpath,'jpg');                           {Grabo JPG en carp. del programa (/pics)}
    rfoto.Picture.LoadFromFile(imgpath);                               {Cargo IMG de la base de datos}
  end else // OK.
  begin
    imgname:= 'sin-foto.jpg';                                    {NO elige nada!!}
    rfoto.Picture.LoadFromFile(f_main.basepic+imgname);          {Cargo IMG x defecto}
  end;
end;

procedure Tf_rece.habdes();
begin
  if b_save.Enabled = true then // antes de grabar
  begin
    rnom.ReadOnly:= false; anom.ReadOnly:= false;
    ing.ReadOnly:= false; ins.ReadOnly:= false;
    rfoto.Enabled:= true; {disponible}
    rfec.ReadOnly:= false; rfec.Button.Enabled:= true;
    faviso.Visible:= true; lcates.Enabled:= true;
    b_nva.Enabled:= false; b_mod.Enabled:= false;
    b_del.Enabled:= false; b_imp.Enabled:= false;
    rnom.SetFocus;
  end else begin
    rnom.ReadOnly:= true; anom.ReadOnly:= true;
    ing.ReadOnly:= true; ins.ReadOnly:= true;
    rfoto.Enabled:= false; {NO dispobible}
    rfec.ReadOnly:= true; rfec.Button.Enabled:= false;
    faviso.Visible:= false; lcates.Enabled:= false;
    b_nva.Enabled:= true; b_mod.Enabled:= true;
    b_del.Enabled:= true; b_imp.Enabled:= true;
    b_nva.SetFocus;
  end;
end;

procedure Tf_rece.b_delClick(Sender: TObject);
begin
  //*Pregunta de Seguridad?
  if MessageDlg('ATENCION!!', 'Está seguro que desea ELIMINAR esta Receta?',
  mtConfirmation,[mbYes, mbNo],0) = mrYes then
  begin
    // Local ---------------------------------------
    qexe.Active:= false;
    qexe.SQL.Text:= 'DELETE FROM recetas WHERE id_rec=:ID';
    qexe.ParamByName('ID').AsInteger:= idre.Value;
    qexe.ExecSQL;
    // Web -----------------------------------------
    if f_main.web = 1 then
    begin
      //*Pregunta de Seguridad?
      if MessageDlg('ATENCION!!', 'Desea ELIMINAR esta Receta también del Sitio Web?',
      mtConfirmation,[mbYes, mbNo],0) = mrYes then
      begin
        wqexe.Active:= false;
        wqexe.SQL.Text:= 'DELETE FROM recetas WHERE id_rec=:ID';
        wqexe.ParamByName('ID').AsInteger:= idre.Value;
        try
          wqexe.ExecSQL;
        except
          showmessage('Receta NO encontrada, no se pudo Eliminar!');
        end;
      end;
    end;
    // OK, fin -------------------------------------
    f_main.recetas();
    close();
  end;
end;

procedure Tf_rece.b_modClick(Sender: TObject);
begin
  b_save.Enabled:= true;
  habdes();
  op:= 'M';
end;

procedure Tf_rece.b_nvaClick(Sender: TObject);
begin
  // limpia!
  rnom.Text:= ''; anom.Text:= '';
  lcates.Text:= ''; rfec.Value:= 0;
  ing.Clear; ins.Clear; visto.Value:= 0;
  // -------------- OK
  id_nva();
  b_save.Enabled:= true;
  habdes();
  op:= 'A';
end;

procedure Tf_rece.b_saveClick(Sender: TObject);
var
  msje: string;
begin
  vacios();
  if OK = 'S' then
  begin
    qexe.Active:= false;
    if op = 'A' then
    begin
      qexe.SQL.Text:= 'INSERT INTO recetas(nomb,autor,fec,ingres,pasos,rank,foto,id_cat) '+
      'VALUES(:RN,:RA,:FE,:IG,:IS,:RK,:FO,:IC)';
      msje:= 'Nueva Receta Guardada correctamente!';
    end else begin
      qexe.SQL.Text:= 'UPDATE recetas SET nomb=:RN,autor=:RA,fec=:FE,ingres=:IG,'+
      'pasos=:IS,rank=:RK,foto=:FO,id_cat=:IC WHERE id_rec=:ID';
      qexe.ParamByName('ID').AsInteger:= idre.Value;
      msje:= 'Receta Editada correctamente!';
    end;
    // Parametros
    qexe.ParamByName('RN').AsString:= trim(rnom.Text);
    qexe.ParamByName('RA').AsString:= trim(anom.Text);
    qexe.ParamByName('FE').AsDate:= rfec.Value;
    qexe.ParamByName('IG').AsString:= ing.Text;
    qexe.ParamByName('IS').AsString:= ins.Text;
    qexe.ParamByName('RK').AsInteger:= visto.Value;
    qexe.ParamByName('FO').AsString:= imgname; // global
    qexe.ParamByName('IC').AsInteger:= lcates.KeyValue;
    qexe.ExecSQL;
    showmessage(msje+#13+'Decida si desea Subir esta actualización a la Web');
    b_save.Enabled:= false;
    habdes();
    f_main.recetas();
  end;
end;

procedure Tf_rece.b_upClick(Sender: TObject);
var
  msje: string;
begin
  //*Pregunta de Seguridad?
  if MessageDlg('ATENCION!!', 'Está seguro que desea Subir esta Receta al Sitio Web?',
  mtConfirmation,[mbYes, mbNo],0) = mrYes then
  begin
    // -------- FALTAN CONTROLES !!
    wqexe.Active:= false;
    if op = 'A' then
    begin
      wqexe.SQL.Text:= 'INSERT INTO recetas(id_rec,nomb,autor,fec,ingres,pasos,rank,foto,id_cat) '+
      'VALUES(:ID,:RN,:RA,:FE,:IG,:IS,:RK,:FO,:IC)';
      msje:= 'Nueva Receta subida correctamente!';
    end else begin {Modifica con Edita o desde Doble clic en main}
      wqexe.SQL.Text:= 'UPDATE recetas SET nomb=:RN,autor=:RA,fec=:FE,ingres=:IG,'+
      'pasos=:IS,rank=:RK,foto=:FO,id_cat=:IC WHERE id_rec=:ID';
      msje:= 'Receta editada correctamente en la web!';
    end;
    // Parametros
    wqexe.ParamByName('ID').AsInteger:= idre.Value;
    wqexe.ParamByName('RN').AsString:= trim(rnom.Text);
    wqexe.ParamByName('RA').AsString:= trim(anom.Text);
    wqexe.ParamByName('FE').AsDate:= rfec.Value;
    wqexe.ParamByName('IG').AsString:= ing.Text;
    wqexe.ParamByName('IS').AsString:= ins.Text;
    wqexe.ParamByName('RK').AsInteger:= visto.Value;
    wqexe.ParamByName('FO').AsString:= imgname; // global
    wqexe.ParamByName('IC').AsInteger:= lcates.KeyValue;
    wqexe.ExecSQL;
    showmessage(msje);
  end;
end;

procedure Tf_rece.vacios();
begin
  OK:= 'N';
  if rnom.Text = '' then
  begin
    showmessage('Debe indicar el NOMBRE de la Receta!');
    rnom.SetFocus;
  end else begin
  if lcates.Text = '' then
  begin
    showmessage('Debe seleccionar una CATEGORIA para la Receta!');
    lcates.SetFocus;
  end else begin
  if rfec.Value = 0 then
  begin
    showmessage('Debe indicar la FECHA de la Receta!');
    rfec.SetFocus;
  end else begin
  if anom.Text = '' then
  begin
    showmessage('Debe indicar el AUTOR de la Receta!');
    anom.SetFocus;
  end else begin
  if ing.Text = '' then
  begin
    showmessage('Debe indicar los INGREDIENTES de la Receta!');
    ing.SetFocus;
  end else begin
  if ins.Text = '' then
  begin
    showmessage('Debe indicar los PASOS/INSTRUCCIONES de la Receta!');
    ins.SetFocus;
  end else OK:= 'S';
  end; end; end; end; end;
end;

procedure Tf_rece.b_impClick(Sender: TObject);
var
  RRep: TStringStream; // Archivo de recurso para reporte!
begin
  RRep:= TStringStream.Create(LazarusResources.Find('ireceta').Value);  // Nombre del archivo agregado
  repo.LoadFromXMLStream(RRep);
  repo.ShowReport;
end;

procedure Tf_rece.repoGetValue(const ParName: String; var ParValue: Variant);
begin
  // Uso variables xq no tengo un query aquí -----
  if parname = 'rn' then parvalue:= rnom.Text;
  if parname = 'ra' then parvalue:= anom.Text;
  if parname = 'rc' then parvalue:= lcates.Text;
  if parname = 'rf' then parvalue:= rfec.Value;
  // ingredientes
  if parname = 'rg1' then parvalue:= ing.Text;
  if parname = 'rg2' then parvalue:= ing2.Text;
  // instrucciones
  if parname = 'rs' then parvalue:= ins.Text;
end;

procedure Tf_rece.repoEnterRect(Memo: TStringList; View: TfrView);
var
  pic_url: string;
begin
  if (View is TfrPictureView) then
  begin
    pic_url:= f_main.basepic+imgname;
    if (View as TfrPictureView).Name = 'fotorec' then // nombre del objeto picture en el reporte
    begin
      (View as TfrPictureView).Visible:= FileExists(pic_url); // chequeamos que exista!
      if (View as TfrPictureView).Visible then
        (View as TfrPictureView).Picture.LoadFromFile(pic_url);
    end;
  end;
end;

initialization
  {$I recursos.lrs}

end.

