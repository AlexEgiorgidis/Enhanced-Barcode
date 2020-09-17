codeunit 63001 "Barcode Setup Initialise"
{

    // Initialise Barcode Setup 
    Subtype = Install;

    trigger OnInstallAppPerCompany();
    begin
        InitialiseSetup;
    end;

    procedure InitialiseSetup();
    var
        BarcodeMaskCharacters: Record "Barcode Mask Character";
    begin
        If Not BarcodeMaskCharacters.get(0) Then begin
            BarcodeMaskCharacters.Init;
            BarcodeMaskCharacters.validate("Character Type", BarcodeMaskCharacters."Character Type"::"Item No.");
            BarcodeMaskCharacters.validate(Character, 'I');
            BarcodeMaskCharacters.insert(true);
        end;

        If Not BarcodeMaskCharacters.get(1) Then begin
            BarcodeMaskCharacters.Init;
            BarcodeMaskCharacters.validate("Character Type", BarcodeMaskCharacters."Character Type"::"Any No.");
            BarcodeMaskCharacters.validate(Character, 'A');
            BarcodeMaskCharacters.insert(true);
        end;

        If Not BarcodeMaskCharacters.get(2) Then begin
            BarcodeMaskCharacters.Init;
            BarcodeMaskCharacters.validate("Character Type", BarcodeMaskCharacters."Character Type"::"Check Digit");
            BarcodeMaskCharacters.validate(Character, 'M');
            BarcodeMaskCharacters.insert(true);
        end;

        If Not BarcodeMaskCharacters.get(3) Then begin
            BarcodeMaskCharacters.Init;
            BarcodeMaskCharacters.validate("Character Type", BarcodeMaskCharacters."Character Type"::"Number Series");
            BarcodeMaskCharacters.validate(Character, 'N');
            BarcodeMaskCharacters.insert(true);
        end;
    End;
}