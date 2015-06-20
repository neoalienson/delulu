Parse.initialize("Lq8BpgkIo7aoDpDOHjeqrKip6uH84elKKgLISFJW", "yFpw0CA2mI2fsGAU4YbGnEFUg5enFiVIYjuhvIHv");

var aTblRslt=null;
/**
 *	[biz_object]
 */
var TableResult=function() {

	/**
	 *	[object] return the interface object
	 */
	return {
		getLedgerData:function(pId, pCb) {
			var Ledger=Parse.Object.extend('Ledger');
			var aQuery=new Parse.Query(Ledger);

			aQuery.addDescending(['updatedAt', 'description']);			
			aQuery.find({
				success:function(pResults) {
					var aContents='';

					if (pResults==null) return;

					for (var aI=0; aI<pResults.length; aI++) {
						if ( pResults[aI]._serverData.household.id!=pId ) continue;

						var aItem=pResults[aI]._serverData;						
						var aEVal=Math.round(parseFloat(aItem.amount)*10)/10;
						var aUpdDate=pResults[aI].updatedAt;

						aUpdDate=aUpdDate.getFullYear()+'-'+
							( (aUpdDate.getMonth()+1>=10)?aUpdDate.getMonth()+1:'0'+(aUpdDate.getMonth()+1) )+'-'+
							( (aUpdDate.getDate()>=10)?aUpdDate.getDate():'0'+(aUpdDate.getDate()) )+' '+
							( (aUpdDate.getHours()>=10)?aUpdDate.getHours():'0'+(aUpdDate.getHours()) )+':'+
							( (aUpdDate.getMinutes()>=10)?aUpdDate.getMinutes():'0'+(aUpdDate.getMinutes()) )+':'+
							( (aUpdDate.getSeconds()>=10)?aUpdDate.getSeconds():'0'+(aUpdDate.getSeconds()) );

						aContents+='<tr> <td>'+aUpdDate+'</td>'+
							'<td>'+aItem.description+'</td>'+
							'<td>$'+aEVal+'</td>'+
							'<td>$'+(Math.round((aEVal*1.1)*10)/10)+'</td> </tr>';
					}	// end -- for (pResults)
					$('#tblBody').html(aContents);

					if (pCb!=null) pCb();
				},
				error:function(pErr) {
					console.log('error');
					console.log(pErr);
				}
			});
		}
	};
};



$(document).ready(function() {
	aTblRslt=new TableResult();

	aTblRslt.getLedgerData('rLooCSzCeV', function() {
		var aJTbl=$('#wrapper').DataTable();

		aJTbl.column(0).data().sort(); // a way to "sort" but seems not ok to "desc"
		//aJTbl.order( [ 1, 'asc' ] );

		$('#wrapperContainer').css({ display: 'block' });
	});
});

