/***************************************************************************
                      pagosperiodicos.qs  -  description
                             -------------------
    begin                : vie jun 26 2004
    copyright            : (C) 2004 by InfoSiAL S.L.
    email                : mail@infosial.com
 ***************************************************************************/
/***************************************************************************
 *                                                                         *
 *   This program is free software; you can redistribute it and/or modify  *
 *   it under the terms of the GNU General Public License as published by  *
 *   the Free Software Foundation; either version 2 of the License, or     *
 *   (at your option) any later version.                                   *
 *                                                                         *
 ***************************************************************************/

/** @file */

/** @class_declaration interna */
////////////////////////////////////////////////////////////////////////////
//// DECLARACION ///////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////
//// INTERNA /////////////////////////////////////////////////////
class interna
{
  var ctx;
  function interna(context)
  {
    this.ctx = context;
  }
  function init()
  {
    this.ctx.interna_init();
  }
  function validateForm()
  {
    return this.ctx.interna_validateForm();
  }
}
//// INTERNA /////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////

/** @class_declaration oficial */
//////////////////////////////////////////////////////////////////
//// OFICIAL /////////////////////////////////////////////////////
class oficial extends interna
{
  function oficial(context)
  {
    interna(context);
  }
  function bufferChanged(fN)
  {
    return this.ctx.oficial_bufferChanged(fN);
  }
}
//// OFICIAL /////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////

/** @class_declaration head */
/////////////////////////////////////////////////////////////////
//// DESARROLLO /////////////////////////////////////////////////
class head extends oficial
{
  function head(context)
  {
    oficial(context);
  }
}
//// DESARROLLO /////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////

/** @class_declaration ifaceCtx */
/////////////////////////////////////////////////////////////////
//// INTERFACE  /////////////////////////////////////////////////
class ifaceCtx extends head
{
  function ifaceCtx(context)
  {
    head(context);
  }
}

const iface = new ifaceCtx(this);
//// INTERFACE  /////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////

/** @class_definition interna */
////////////////////////////////////////////////////////////////////////////
//// DEFINICION ////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////
//// INTERNA /////////////////////////////////////////////////////

function interna_init()
{
  var _i = this.iface;
  var cursor = this.cursor();

  connect(cursor, "bufferChanged(QString)", _i, "bufferChanged");
}

/** \C El nombre del fichero de destino debe indicarse
\end */
function interna_validateForm()
{
  var cursor = this.cursor();
  var diaDesde = parseFloat(cursor.valueBuffer("fechadesde").toString().left(10).right(2));
  var diaPago = parseFloat(cursor.valueBuffer("diapago"));

  if (diaDesde > diaPago) {
    sys.warnMsgBox(sys.translate("El d�a de pago debe ser posterior al d�a de la fecha de inicio"));
    return false;
  }

  return true;
}

//// INTERNA /////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////

/** @class_definition oficial */
//////////////////////////////////////////////////////////////////

//// OFICIAL /////////////////////////////////////////////////////
function oficial_bufferChanged(fN)
{
  var cursor = this.cursor();

  var diaPago = parseFloat(cursor.valueBuffer("diapago"));

  if (diaPago > 31) {
    sys.warnMsgBox(sys.translate("El d�a de pago debe ser como m�ximo el d�a 31."));
    return false;
  }

  return true;
}
//// OFICIAL /////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////

/** @class_definition head */
/////////////////////////////////////////////////////////////////
//// DESARROLLO /////////////////////////////////////////////////

//// DESARROLLO /////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////