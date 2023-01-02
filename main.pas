unit main;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, spkt_Tab, Forms, Controls, Graphics, Dialogs,
  ExtCtrls, Buttons, DBGrids, Menus, StdCtrls, DbCtrls, importar_csv,
  categorias, db, ZConnection, ZDataset, receta, windows, sistema, LR_Class,
  LR_DBSet, LResources, lclintf;

type

  { Tf_main }

  Tf_main = class(TForm)
    b_imp: TBitBtn;
    b_nva: TBitBtn;
    cates: TDBLookupComboBox;
    ordena: TComboBox;
    dcates: TDataSource;
    datos: TDataSource;
    can: TLabel;
    drepo: TfrDBDataSet;
    Image1: TImage;
    link_face: TLabel;
    link_wsc: TLabel;
    repo: TfrReport;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Shape2: TShape;
    xpal: TLabeledEdit;
    lista: TDBGrid;
    sep1: TMenuItem;
    m_quit: TMenuItem;
    m_cat: TMenuItem;
    m_sis: TMenuItem;
    m_inicio: TMenuItem;
    TopMenu: TMainMenu;
    Shape1: TShape;
    SpkTab1: TSpkTab;
    conex: TZConnection;
    qlista: TZQuery;
    qcates: TZQuery;
    procedure b_impClick(Sender: TObject);
    procedure b_nvaClick(Sender: TObject);
    procedure catesSelect(Sender: TObject);
    procedure ck_pubChange(Sender: TObject);
    procedure ordenaSelect(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure link_cocClick(Sender: TObject);
    procedure link_faceClick(Sender: TObject);
    procedure link_faceMouseEnter(Sender: TObject);
    procedure link_faceMouseLeave(Sender: TObject);
    procedure link_wscClick(Sender: TObject);
    procedure link_wscMouseEnter(Sender: TObject);
    procedure link_wscMouseLeave(Sender: TObject);
    procedure listaDblClick(Sender: TObject);
    procedure m_catClick(Sender: TObject);
    procedure m_impClick(Sender: TObject);
    procedure m_sisClick(Sender: TObject);
    procedure xpalChange(Sender: TObject);
  private
    { private declarations }
    procedure fuente();
  public
    { public declarations }
    procedure recetas();
    var
      basepic: string;
      web: byte;
  end;

var
  f_main: Tf_main;
  cond: string;

implementation

{$R *.lfm}

{ Tf_main }

procedure Tf_main.FormActivate(Sender: TObject);
begin
  {Conecta a la base de edatos ---------------------}
  conex.HostName:= '';
  conex.Database:= ExtractFilePath(Application.EXEName)+'db\rec_data.db';
  conex.LibLocation:= ExtractFilePath(Application.EXEName)+'db\sqlite3_64.dll';
  try
    conex.Connect;
  except
    showmessage('Error! No se pudo conectar con la Base de Datos!'+#13
    +'El sistema se cerrará, contacte con el soporte técnico.'+#13
    +'Email: webscom.ar@gmail.com');
    close();
  end;
  if conex.Connected then
  begin
    DefaultFormatSettings.DecimalSeparator:= ',';
    DefaultFormatSettings.ThousandSeparator:= '.';
    {Carga recetas}
    recetas();
    {Carga categorías}
    qcates.Active:= false;
    qcates.SQL.Text:= 'SELECT * FROM categorias ORDER BY cnom ASC';
    qcates.Open;
    cates.Items.Add('_TODAS'); // agrego esta opcion
    {Otras opciones}
    basepic:= ExtractFilePath(Application.EXEName)+'pics\';
    b_nva.SetFocus;
    // ---------------------------------------------
    MessageDlg('Hola!','Bienvenido a Cocinare!'+#13+
    '<Recetas en tu bolsillo>',mtInformation,[mbOK],0);
  end;
  // OK
end;

procedure Tf_main.recetas();
begin
  qlista.Active:= false;
  qlista.SQL.Text:= 'SELECT r.*,c.* FROM recetas AS r '+
  'INNER JOIN categorias AS c ON r.id_cat=c.id_cat ORDER BY r.nomb ASC';
  qlista.Open;
  can.Caption:= inttostr(qlista.RecordCount);
end;

procedure Tf_main.fuente();
begin
  // Adding the font ..
  AddFontResource(PChar('BRLNSDB.TTF'));
  SendMessage(HWND_BROADCAST, WM_FONTCHANGE, 0, 0);
  {// Removing the font
  RemoveFontResource(PChar('XXXFont.TTF'));
  SendMessage(HWND_BROADCAST, WM_FONTCHANGE, 0, 0);}
end;

procedure Tf_main.xpalChange(Sender: TObject);
var
  fpal: string;
begin
  cates.KeyField:= '';
  qlista.Active:= false;
  if (xpal.Text <> '') then
  begin
    fpal:= uppercase(trim(xpal.Text)); // Re-escribo la sentencia SQL
    qlista.SQL.Text:= 'SELECT r.*,c.* FROM recetas AS r '+
    'INNER JOIN categorias AS c ON r.id_cat=c.id_cat '+
    'WHERE r.nomb LIKE :PAL ORDER BY r.nomb ASC';
    qlista.ParamByName('PAL').AsString:= '%'+fpal+'%';
    qlista.Open;
    can.Caption:= inttostr(qlista.RecordCount);
  end else
    recetas();
end;

procedure Tf_main.catesSelect(Sender: TObject);
begin
  if cates.Text <> '_TODAS' then
  begin
    //showmessage(inttostr(cates.KeyValue));
    ordena.Text:= 'Nombre';
    qlista.Active:= false;
    qlista.SQL.Text:= 'SELECT r.*,c.* FROM recetas AS r '+
    'INNER JOIN categorias AS c ON r.id_cat=c.id_cat '+
    'WHERE r.id_cat=:IC ORDER BY r.nomb ASC';
    qlista.ParamByName('IC').AsInteger:= cates.KeyValue;
    qlista.Open;
    can.Caption:= inttostr(qlista.RecordCount);
  end else
    recetas();
end;

procedure Tf_main.ck_pubChange(Sender: TObject);
begin
  qlista.Active:= false;
  qlista.SQL.Text:= 'SELECT r.*,c.* FROM recetas AS r '+
  'INNER JOIN categorias AS c ON r.id_cat=c.id_cat ORDER BY r.nomb ASC';
  qlista.Open;
  can.Caption:= inttostr(qlista.RecordCount);
  cates.Text:= '';
  ordena.Text:= 'Nombre';
end;

procedure Tf_main.ordenaSelect(Sender: TObject);
var
 ord: string;
begin
  qlista.Active:= false;
  {opciones}
  case ordena.Text of
   'Nombre': ord:= 'r.nomb ASC';
   'Categoría': ord:= 'c.cnom ASC';
   'Veces Vista': ord:= 'r.rank DESC';
  end;
  {Armamos la cadena select}
  qlista.SQL.Text:= 'SELECT r.*,c.* FROM recetas AS r '+
  'INNER JOIN categorias AS c ON r.id_cat=c.id_cat ORDER BY '+ord;
  qlista.Open;
  can.Caption:= inttostr(qlista.RecordCount);
  cates.Text:= '';
end;

procedure Tf_main.listaDblClick(Sender: TObject);
var
 S: string;
begin
  if not qlista.IsEmpty then
  begin
    f_rece:= Tf_rece.Create(Self);
    // Datos
    f_rece.rnom.Text:= qlista.FieldByName('nomb').Text;
    f_rece.anom.Text:= qlista.FieldByName('autor').Text;
    f_rece.carga_cats();
    f_rece.lcates.KeyValue:= qlista.FieldByName('id_cat').Value;
    f_rece.rfec.Value:= qlista.FieldByName('fec').Value;
    f_rece.rfec.Button.Enabled:= false;
    f_rece.imgname:= qlista.FieldByName('foto').Text;   // foto actual, sin Path
    f_rece.rfoto.Picture.LoadFromFile(basepic+qlista.FieldByName('foto').Text);
    S:= qlista.FieldByName('ingres').Value;
    if length(S) < 250 then
    begin
      f_rece.ing.Text:= S;
      f_rece.ing2.Text:= '';
    end else begin
      f_rece.ing.Text:= copy(S,1,250);
      f_rece.ing2.Text:= copy(S,251,length(S));
    end;
    f_rece.ins.Text:= qlista.FieldByName('pasos').Value;
    f_rece.visto.Value:= qlista.FieldByName('rank').Value;
    f_rece.idre.Value:= qlista.FieldByName('id_rec').Value;
    // Habilitaciones?
    f_rece.op:= 'M'; // viendo receta, se abre como "Modifica"
    f_rece.b_nva.Enabled:= true;
    f_rece.b_mod.Enabled:= true;
    f_rece.b_del.Enabled:= true;
    f_rece.ShowModal;
  end;
end;

procedure Tf_main.b_nvaClick(Sender: TObject);
begin
  f_rece:= Tf_rece.Create(Self);
  f_rece.carga_cats();
  f_rece.b_save.Enabled:= true; // importante, activa
  f_rece.op:= 'A';
  f_rece.ShowModal;
end;

procedure Tf_main.m_catClick(Sender: TObject);
begin
  f_cates:= Tf_cates.Create(Self);
  f_cates.ShowModal;
end;

procedure Tf_main.m_impClick(Sender: TObject);
begin
  f_import:= Tf_import.Create(Self);
  f_import.ShowModal;
end;

procedure Tf_main.m_sisClick(Sender: TObject);
begin
  f_sis:= Tf_sis.Create(Self);
  f_sis.ShowModal;
end;

procedure Tf_main.b_impClick(Sender: TObject);
var
  RRep: TStringStream; // Archivo de recurso para reporte!
begin
  RRep:= TStringStream.Create(LazarusResources.Find('ilistado').Value);  // Nombre del archivo agregado
  repo.LoadFromXMLStream(RRep);
  repo.ShowReport;
end;

procedure Tf_main.link_cocClick(Sender: TObject);
begin
  OpenURL('https://www.webscom.com.ar');
end;

procedure Tf_main.link_wscClick(Sender: TObject);
begin
  OpenURL('https://www.webscom.com.ar');
end;

procedure Tf_main.link_wscMouseEnter(Sender: TObject);
begin
 link_wsc.Font.Color:= clBlue;
end;

procedure Tf_main.link_wscMouseLeave(Sender: TObject);
begin
 link_wsc.Font.Color:= clDefault;
end;

procedure Tf_main.link_faceClick(Sender: TObject);
begin
  OpenURL('https://www.facebook.com/Cocinare/');
end;

procedure Tf_main.link_faceMouseEnter(Sender: TObject);
begin
 link_face.Font.Color:= clBlue;
end;

procedure Tf_main.link_faceMouseLeave(Sender: TObject);
begin
 link_face.Font.Color:= clDefault;
end;

initialization
  {$I recursos.lrs}

end.

