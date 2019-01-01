CREATE TRIGGER dbo.tg_channel_permission
ON dbi.
AFTER INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    --update trigger was ist relevant? nicht relevant wenn lieferant sich ändert!! 
    --darum mit IF UPDATE() überprüfen

    SELECT * FROM inserted
    --IF UPDATE(ekpreis)--UPDATE sagt nur aus,ob spalte geändert wird. 
    --UPDATE liefert bei INSERT TRUE!!
    --BEGIN
     --   INSERT INTO mipo.preise(artnr,preis, typ)
     --   SELECT artnr, ekpreis, 'E'
     --   FROM inserted
    --END

    --IF UPDATE(vkpreis) --UPDATE sagt nur aus,ob spalte geändert wird.
    --BEGIN
    --     INSERT INTO mipo.preise(artnr,preis, typ)
    --    SELECT artnr, ekpreis, 'V'
     --   FROM inserted
    --END
END