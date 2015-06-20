
Parse.initialize("Lq8BpgkIo7aoDpDOHjeqrKip6uH84elKKgLISFJW", "yFpw0CA2mI2fsGAU4YbGnEFUg5enFiVIYjuhvIHv");

/**
 *	[biz_object]
 */
var ReportObject=function() {

	var _ledgerResults={};

	/**
	 *	object
	 */
	return {
		// TODO: for testing purpose only
		_test:function() {
			var Ledger=Parse.Object.extend("Ledger");
			var aQuery=new Parse.Query(Ledger);
			aQuery.get('VQxxPHjafA', {
			    success: function(ledger) {
			        console.log(ledger);
			    }, 
			    error: function(object, error) {
			        console.log('error found');
			        console.log(object);
			        console.log(error);
			    }
			}); 			
		},
		/**
		 *	[getter] return ledger results
		 */
		getLedgerResults:function() {
			return _ledgerResults;
		},
		/**
		 *	[biz] get ledger result based on helperId
		 */
		queryLedgerByHouseHoldId:function(pHouseHoldId, cb) {
			var Ledger=Parse.Object.extend("Ledger");
			var aQuery=new Parse.Query(Ledger);
			
			// not yet work on equalTo, use brute force "find" for the angelhack
			/*aQuery.include('household');
			aQuery=aQuery.equalTo('household', {
				"__type": "pointer",
				"className": "Ledger",
				"objectId": "rLooCSzCeV"
			});
			
			aQuery.find({
				success: function(results) { 
					console.log(results); 
					console.log(results.length);
				},
				error: function(error) {
					console.log('error > ');
					console.log(error);
				}
			});*/
	
			aQuery.find({
				success:function(results) {
					if (results!=null) {
						for (var aI=0; aI<results.length; aI++) {
							var aItem=results[aI]._serverData;

							if (aItem.household.id!=pHouseHoldId) continue;

							/*var aExists=false;
							if (_ledgerResults[aItem.description]!=undefined && _ledgerResults[aItem.description]!=null) {
								aExists=true;
							}

							if (aExists==true) {
								_ledgerResults[aItem.description]=_ledgerResults[aItem.description] + parseFloat(aItem.amount);
							} else {
								_ledgerResults[aItem.description]=parseFloat(aItem.amount);
							}*/

							var aItemType=aItem.type;
							if (aItemType=='deposit') {
								var aEVal=_ledgerResults[aItem.description];

								if (aEVal!=undefined && aEVal!=null) {
									aEVal+=parseFloat(aItem.amount);
									_ledgerResults[aItem.description]=aEVal;
								} else {
									_ledgerResults[aItem.description]=parseFloat(aItem.amount);
								}	// end -- if ()
							} else {
								var aEVal=_ledgerResults['your household'];

								if (aEVal!=undefined && aEVal!=null) {
									aEVal+=parseFloat(aItem.amount);
									_ledgerResults['your household']=aEVal;
								} else {
									_ledgerResults['your household']=parseFloat(aItem.amount);
								}
							}

						}	// end -- for (summation)
					}	// end -- if (results valid)
console.log(_ledgerResults);
					if (cb!=null) {
						cb();
					}

				},
				error:function(pErr) {
					console.log('error');
					console.log(pErr);
				}
			});
		},

		renderExpense:function() {
			var categories=[];
			var dollars=[];

			var colors = ['#F43F4F','#FFCC49','#FFCC49','#FFCC49',
				'#F43F4F','#FFCC49','#FFCC49','#FFCC49',
				'#F43F4F','#FFCC49','#FFCC49','#FFCC49',
				'#F43F4F','#FFCC49','#FFCC49','#FFCC49',
				'#F43F4F','#FFCC49','#FFCC49','#FFCC49',
				'#F43F4F','#FFCC49','#FFCC49','#FFCC49',
				'#F43F4F','#FFCC49','#FFCC49','#FFCC49'];	

			/*
			 *	build the categories and prices back
			 */
			var aKeys=Object.keys(_ledgerResults);
			var aMaxExpense=0;
			var aDepositMoney=0;

			for (var aI=0; aI<aKeys.length; aI++) {
				var aKey=aKeys[aI];
				var aExpenseVal=parseFloat(_ledgerResults[aKey]);

				if (aKey=='Deposit money') {
					aDepositMoney=aExpenseVal;
					continue;	// ignore "Deposit money"
				}

				categories.push(aKey);
				dollars.push(aExpenseVal);

				if (aExpenseVal>aMaxExpense) aMaxExpense=aExpenseVal; 
			}
			// hardcode country / city average
			if (categories.length==1) {
				var aEVal=parseFloat(dollars[0]);
				dollars.push(aEVal*0.8);
				dollars.push(10);
				dollars.push(aEVal);
				dollars.push(aEVal*1.1);

				aMaxExpense=aEVal*1.1;

				categories.push('Country average');
				categories.push('');
				categories.push('your household');
				categories.push('Meifoo');
			}

			$('#divDepositMoney').html('* total deposit money is $'+aDepositMoney).
				css({
					'display': 'block'
				}
			);

			//var grid = d3.range(25).map(function(i){ 25 tick points ( / 10)
			var grid = d3.range((aMaxExpense)/10 ).map(function(i){
				return {'x1':0,'y1':0,'x2':0,'y2':200};
			});

			var tickVals = grid.map(function(d,i){
				if(i>0){ return i*10; }
				else if(i===0){ return "100";}
			});

			var xscale = d3.scale.linear()
							//.domain([10,250])
							.domain([10, aMaxExpense*1.1])
							//.range([0,722]);
							.range([0, 800]);

			var yscale = d3.scale.linear()
							.domain([0,categories.length])
							// .range([0,480]);
							.range([10,200]); 

			var colorScale = d3.scale.quantize()
							.domain([0,categories.length])
							.range(colors);

			var canvas = d3.select('#wrapper')
							.append('svg')
							.attr({'width':900,'height':230});

			/*var grids = canvas.append('g')
							  .attr('id','grid')
							  .attr('transform','translate(150,10)')
							  .selectAll('line')
							  .data(grid)
							  .enter()
							  .append('line')
							  .attr({'x1':function(d,i){ return i*30; },
									 'y1':function(d){ return d.y1; },
									 'x2':function(d,i){ return i*30; },
									 'y2':function(d){ return d.y2; },
								})
							  .style({'stroke':'#adadad','stroke-width':'1px'});
			*/

			var	xAxis = d3.svg.axis();
				xAxis
					.orient('bottom')
					.scale(xscale)
					.tickValues(tickVals);

			var	yAxis = d3.svg.axis();
				yAxis
					.orient('left')
					.scale(yscale)
					.tickSize(2)
					.tickFormat(function(d,i){ return categories[i]; })
					.tickValues(d3.range(17));

			var y_xis = canvas.append('g')
							  .attr("transform", "translate(150,0)")
							  .attr('id','yaxis')
							  .call(yAxis);

			var x_xis = canvas.append('g')
							  //.attr("transform", "translate(150,480)")
							  .attr("transform", "translate(150,200)")
							  .attr('id','xaxis')
							  .call(xAxis);

			var chart = canvas.append('g')
								//.attr("transform", "translate(150,-20)")
								.attr("transform", "translate(150,0)")
								.attr('id','bars')
								.selectAll('rect')
								.data(dollars)
								.enter()
								.append('rect')
								.attr('height',19)
								//.attr({'x':0,'y':function(d,i){ return yscale(i)+19; }})
								.attr({'x':0,'y':function(d,i){ return yscale(i); }})
								.style('fill',function(d,i){ return colorScale(i); })
								.attr('width',function(d){ return 0; });


			var transit = d3.select("svg").selectAll("rect")
							    .data(dollars)
							    .transition()
							    .duration(1000) 
							    .attr("width", function(d) {return xscale(d); });

			var transitext = d3.select('#bars')
								.selectAll('text')
								.data(dollars)
								.enter()
								.append('text')
								//.attr({'x':function(d) {return xscale(d)-200; },'y':function(d,i){ return yscale(i)+35; }})
								//.attr({'x':function(d) {return xscale(d)-200; },'y':function(d,i){ return yscale(i)+15; }})
								.attr({'x':function(d) {
									return xscale(d)/2;

								},'y':function(d,i){ return yscale(i)+15; }})
								.text(function(d){ return d+"$"; }).style({'fill':'#fff','font-size':'14px'});
		}


	};
};

/* ##################################################### */

var aRptObj=new ReportObject();

$(document).ready(function() {
	//aRptObj._test();
	aRptObj.queryLedgerByHouseHoldId('rLooCSzCeV', function() { aRptObj.renderExpense(); });
});
