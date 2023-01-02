program cocinare;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}{$IFDEF UseCThreads}
  cthreads,
  {$ENDIF}{$ENDIF}
  Interfaces, // this includes the LCL widgetset
  Forms, main, categorias, zcomponent, receta, sistema,
  lazreportpdfexport, Translations, LResources
  { you can add units after this };

{$R *.res}

function TranslateUnitResourceStrings: boolean;		// Funcion de Traduccion desde recursos.lrs
var
  ressys, resjin, resrep: TLResource;
  POFile_sys, POFile_jin, POFile_rep: TPOFile;
begin
  ressys:= LazarusResources.Find('lclstrconsts.es','PO');
  resjin:= LazarusResources.Find('jinputconsts.es','PO');
  resrep:= LazarusResources.Find('lr_const.es','PO');
  POFile_sys:= TPOFile.Create;
  POFile_jin:= TPOFile.Create;
  POFile_rep:= TPOFile.Create;
  try
    POFile_sys.ReadPOText(ressys.Value);
    Result:= Translations.TranslateUnitResourceStrings('lclstrconsts',POFile_sys);
    POFile_jin.ReadPOText(resjin.Value);
    Result:= Translations.TranslateUnitResourceStrings('jinputconsts',POFile_jin);
    POFile_rep.ReadPOText(resrep.Value);
    Result:= Translations.TranslateUnitResourceStrings('lr_const',POFile_rep);
  finally
    POFile_sys.Free;
	POFile_jin.Free;
    POFile_rep.Free;
  end;
end;

begin
  RequireDerivedFormResource:=True;
  Application.Initialize;
  TranslateUnitResourceStrings;
  Application.CreateForm(Tf_main, f_main);
  Application.CreateForm(Tf_cates, f_cates);
  Application.CreateForm(Tf_rece, f_rece);
  Application.CreateForm(Tf_sis, f_sis);
  Application.Run;
end.

