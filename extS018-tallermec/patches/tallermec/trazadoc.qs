
/** @class_declaration funServiciosCli */
//////////////////////////////////////////////////////////////////
//// FUN_SERVICIOS_CLI /////////////////////////////////////////////////////
class funServiciosCli extends oficial {
	var SERVICIOS:Number = 7;
	function funServiciosCli( context ) { oficial( context ); }
	function init() { return this.ctx.funServiciosCli_init(); }
	function datosServicioCli(codigo:String) {
		return this.ctx.funServiciosCli_datosServicioCli(codigo);
	}
	function dibOrigenSerCli(codigo:String, fila:Number):Number {
		return this.ctx.funServiciosCli_dibOrigenSerCli(codigo, fila);
	}
	function dibDestinoSerCli(codigo:String, fila:Number):Number {
		return this.ctx.funServiciosCli_dibDestinoSerCli(codigo, fila);
	}
	function dibOrigenAlbCli(codigo:String, fila:Number):Number {
		return this.ctx.funServiciosCli_dibOrigenAlbCli(codigo, fila);
	}
}
//// FUN_SERVICIOS_CLI /////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////

/** @class_definition funServiciosCli */
/////////////////////////////////////////////////////////////////
//// FUN_SERVICIOS_CLI /////////////////////////////////////////////////

function funServiciosCli_init()
{
	this.iface.__init();

	var cursor:FLSqlCursor = this.cursor();
	var tipo:String = cursor.valueBuffer("tipo");
	var codigo:String = cursor.valueBuffer("codigo");

	this.iface.tblDocs.setNumCols(8);
	this.iface.tblDocs.setColumnWidth(0, 100);
	this.iface.tblDocs.setColumnWidth(1, 100);
	this.iface.tblDocs.setColumnWidth(2, 100);
	this.iface.tblDocs.setColumnWidth(3, 100);
	this.iface.tblDocs.setColumnWidth(4, 100);
	this.iface.tblDocs.setColumnWidth(5, 100);
	this.iface.tblDocs.setColumnWidth(7, 100);
	this.iface.tblDocs.hideColumn(6);
	this.iface.tblDocs.setColumnLabels("/", "Presupuestos/Pedidos/Albaranes/Facturas/Recibos/Pagos/Servicios/Servicios");

	this.iface.filaActual = 0;
	switch (tipo) {
		case "servicioscli": {
			this.iface.tblDocs.insertRows(this.iface.tblDocs.numRows());
			this.iface.tblDocs.setText(0, this.iface.SERVICIOS, codigo);
			this.iface.dibDestinoSerCli(codigo, 0);
			this.iface.clienteProveedor = "cliente";
			break;
		}
		case "albaranescli": {
			this.iface.dibOrigenSerCli(codigo, 0);
			break;
		}
	}
}

/** \D Muestra los datos principales de la factura indicada
@param	codigo: C�digo del albar�n
\end */
function funServiciosCli_datosServicioCli(codigo:String)
{
	var util:FLUtil = new FLUtil;
	var qry:FLSqlQuery = new FLSqlQuery();
	with (qry) {
		setTablesList("servicioscli");
		setSelect("codcliente, total, fecha");
		setFrom("servicioscli");
		setWhere("codigo = '" + codigo + "'");
		setForwardOnly(true);
	}
	if (!qry.exec())
		return false;
	if (!qry.first())
		return false;

	var texto:String = util.translate("scripts", "Servicio %1\nCliente %2 - \nImporte: %3\nFecha: %4").arg(codigo).arg(qry.value("codcliente")).arg(util.roundFieldValue(qry.value("total"), "servicioscli", "total")).arg(util.dateAMDtoDMA(qry.value("fecha")));
	this.child("lblDatosDoc").text = texto;
}


/** Dibuja los pedidos que originan el albar�n de cliente indicado, a partir de la fila de la tabla indicada
@param	codigo: C�digo del albar�n
@param	fila: Fila en la que comenzar a dibujar
@return	�ltima fila dibujada
\end */
function funServiciosCli_dibOrigenAlbCli(codigo:String, fila:Number):Number
{
	var qryServicios:FLSqlQuery = new FLSqlQuery();
	with (qryServicios) {
		setTablesList("servicioscli,albaranescli");
		setSelect("s.numservicio");
		setFrom("servicioscli s INNER JOIN albaranescli a ON s.idalbaran = a.idalbaran");
		setWhere("a.codigo = '" + codigo + "' GROUP BY s.numservicio ORDER BY s.numservicio");
		setForwardOnly(true);
	}
	if (!qryServicios.exec())
		return this.iface.__dibOrigenAlbCli(codigo, fila);

	if (!qryServicios.size())
		return this.iface.__dibOrigenAlbCli(codigo, fila);

	while (qryServicios.next()) {
		this.iface.tblDocs.insertRows(fila);

		debug(fila);
		this.iface.tblDocs.setText(fila, this.iface.SERVICIOS, qryServicios.value("s.numservicio"));
	}
	return fila;
}



/** Dibuja los albaranes destino del servicio de cliente indicado, a partir de la fila de la tabla indicada
@param	codigo: C�digo del servicio
@param	fila: Fila en la que comenzar a dibujar
@return	�ltima fila dibujada
\end */
function funServiciosCli_dibDestinoSerCli(codigo:String, fila:Number):Number
{
	var qryAlbaranes:FLSqlQuery = new FLSqlQuery();
	with (qryAlbaranes) {
		setTablesList("servicioscli,albaranescli,lineasalbaranescli");
		setSelect("a.codigo");
		setFrom("servicioscli s INNER JOIN albaranescli a ON s.idalbaran = a.idalbaran");
		setWhere("s.numservicio = '" + codigo + "' GROUP BY a.codigo ORDER BY a.codigo");
		setForwardOnly(true);
	}

	if (!qryAlbaranes.exec())
		return -1;
	while (qryAlbaranes.next()) {
		fila++;

		if (this.iface.tblDocs.numRows() == fila)
			this.iface.tblDocs.insertRows(fila);
		this.iface.tblDocs.setText(fila, this.iface.ALBARANES, qryAlbaranes.value("a.codigo"));
		fila = this.iface.dibDestinoAlbCli(qryAlbaranes.value("a.codigo"), fila);
		if (fila == -1)
			return -1;
	}
	return fila;
}

function funServiciosCli_dibOrigenSerCli(codigo:String, fila:Number):Number
{
	var qryAlbaranes:FLSqlQuery = new FLSqlQuery();
	with (qryAlbaranes) {
		setTablesList("servicioscli,albaranescli");
		setSelect("s.numservicio");
		setFrom("servicioscli s INNER JOIN albaranescli a ON s.idalbaran = a.idalbaran");
		setWhere("a.codigo = '" + codigo + "' GROUP BY s.numservicio ORDER BY s.numservicio");
		setForwardOnly(true);
	}

	if (!qryAlbaranes.exec())
		return -1;
	while (qryAlbaranes.next()) {
		fila++;

		if (this.iface.tblDocs.numRows() == fila)
			this.iface.tblDocs.insertRows(fila);
		this.iface.tblDocs.setText(fila, this.iface.SERVICIOS, qryAlbaranes.value("s.numservicio"));
	}
}
//// FUN_SERVICIOS_CLI ///////////////////////////////////////////
/////////////////////////////////////////////////////////////////

