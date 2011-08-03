unit uWmiClassTree;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ComCtrls;

type
  TFrmWmiClassTree = class(TForm)
    Label1: TLabel;
    CbNamespaces: TComboBox;
    TreeViewClasses: TTreeView;
    BtnFillTree: TButton;
    LabelStatus: TLabel;
    ProgressBar1: TProgressBar;
    procedure FormCreate(Sender: TObject);
    procedure BtnFillTreeClick(Sender: TObject);
    procedure CbNamespacesChange(Sender: TObject);
  private
    procedure FillTree(const Namesoace:string);
    procedure SetStaus(const Msg:string);
  public
  end;


implementation

uses
  ComObj,
  ActiveX,
  uWmi_Metadata;

{$R *.dfm}


procedure TFrmWmiClassTree.BtnFillTreeClick(Sender: TObject);
begin
  FillTree(CbNamespaces.Text);
end;

procedure TFrmWmiClassTree.CbNamespacesChange(Sender: TObject);
begin
  FillTree(CbNamespaces.Text);
end;

procedure TFrmWmiClassTree.FillTree(const Namesoace: string);
Var
  Root        : TTreeNode;
  Node        : TTreeNode;
  WmiClasses  : TStringList;
  WmiClass    : string;
  i           : Integer;

  procedure GetSubClasses(AClass:string;ANode:TTreeNode);
  var
    SubClass    : string;
    lNode       : TTreeNode;
    SubClasses  : TStringList;
  begin
   SubClasses:=TStringList.Create;
   try
    SetStaus(Format('Gettting Sub Classes of %s',[AClass]));
    GetListWmiSubClasses(Namesoace,AClass,SubClasses);
    if SubClasses.Count>0 then
    for SubClass in SubClasses do
    begin
     lNode:=TreeViewClasses.Items.AddChild(ANode,SubClass);
     GetSubClasses(SubClass,lNode);
    end;
   finally
    SubClasses.Free;
   end;
  end;

begin
   WmiClasses:=TStringList.Create;
   try
     SetStaus('Gettting Parent Classes');
     GetListWmiParentClasses(Namesoace,WmiClasses);
     TreeViewClasses.Items.BeginUpdate;
     TreeViewClasses.Items.Clear;
     Root:=TreeViewClasses.Items.Add(nil,Namesoace);
     ProgressBar1.Max:=WmiClasses.Count;
     try
      for i:=0 to WmiClasses.Count-1 do
      begin
        ProgressBar1.Position:=i;
        WmiClass:=WmiClasses[i];
        Node:=TreeViewClasses.Items.AddChild(root,WmiClass);
        GetSubClasses(WmiClass,Node);
      end;

     finally
       TreeViewClasses.Items.EndUpdate;
       TreeViewClasses.Items.Item[0].Expand(True);
     end;
   finally
     WmiClasses.Free;
     SetStaus('');
     ProgressBar1.Position:=0;
   end;
end;

procedure TFrmWmiClassTree.FormCreate(Sender: TObject);
begin
  {
   SetStaus('');
   SetStaus('Loading Wmi namespaces');
   GetListWMINameSpaces(CbNamespaces.Items);
   CbNamespaces.ItemIndex:=0;
   FillTree(CbNamespaces.Text);
   }
end;

procedure TFrmWmiClassTree.SetStaus(const Msg: string);
begin
  LabelStatus.Caption:=Msg;
  LabelStatus.Update;
end;

end.