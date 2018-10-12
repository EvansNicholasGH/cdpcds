const cdpcds = artifacts.require("cdpcds");
let instance;//holds the contract instance globaly
let a0, a1, a2, a3, a4;//account variables also global

//all testing is done here
//TEST 1
contract('Testing CDPCDS', async (accounts) => {
    //Define Contract Globals:a0 =  accounts[0];
        a1 = accounts[1];
        a2 = accounts[2];
        a3 = accounts[3];
        a4 = accounts[4];
        let initialBalance = web3.eth.getBalance(a2).toNumber();
        let finalBalance;

    //README:

    //it statmements define single test. should end with assertion/s. 
    //first one assigns deployed contract instance to 'instance' variable, and acounts to their respective variables.
    //it calls makeCDSOrder from acc1 with 10 ether as collateral.
    //the assert checks if the CDS was successfully created by checking for equality between acc1 and the first data point of getInfo ( the maker) for cds with ID 0.

    //FYI: for view functions (functions that return data and dont change the state of the blockchain)
    //use instance.XYZmethod.call(paramValue) instead of instance.XYZmethod(paramvalue)

    //USE AFTER DATA CALL TO PRINT DATA
    //console.log("Maker:           "+data[0]+"\n"+"MakerCollateral: "+data[1]+"\n"+"Taker:           "+data[2]+"\n"+"TakerCollateral: "+data[3]+"\n"+"Premium:         "+data[4]+"\n"+"Payed:           "+data[5]+"\n"+"ContractBalance: "+data[6]+"\n");
    //USE AFTER DATA CALL TO PRINT DATA

    //reminder: this is javascript so we can get very creative with our tests. loops, external file logs, dynamic variables you name it. 

    it("Should deploy new conract and create CDP", async () => {
        instance = await cdpcds.deployed();        
        await instance.makeCDSOrder(1000000000000000000,{from: a1, value: 10000000000000000000});
        let data = await instance.getInfo.call(0);
        assert.equal(a1,data[0]);
        assert.equal(0,data[6].toNumber());      
   
    });
// return(allCDSs[_ID].maker, allCDSs[_ID].makerCollateral, allCDSs[_ID].taker, allCDSs[_ID].takerCollateral, allCDSs[_ID].premium, allCDSs[_ID].payed, cont.balance);
    //fills the CPD, you know how it goes now. pretty simple
    it("Should fill CDP", async () => { 
        let transactionInfo = await instance.fillCDSOrder(0,1539068400,{value:3000000000000000000,from: a2});
        finalBalance = web3.eth.getBalance(a2).toNumber();
        let tx = await web3.eth.getTransaction(transactionInfo.tx);
        let spentOnTransaction = tx.gasPrice.mul(transactionInfo.receipt.gasUsed)              
        let data = await instance.getInfo.call(0); 
        assert.equal(finalBalance,initialBalance-3e18-spentOnTransaction); 
        assert.equal(a2,data[2]);
        assert.equal(1,data[6].toNumber());
    });
    it("correct balance after requesting premium  #1", async () => {         
        await instance.requestPremium(0,1539154800);           
        data = await instance.getInfo.call(0); 
        assert.equal(data[3].toNumber(),3e18);
        assert.equal(finalBalance,web3.eth.getBalance(a2).toNumber());
    });
    it("correct balance after requesting premium #2", async () => { 
        await instance.requestPremium(0,1539327600);    
        let data = await instance.getInfo.call(0);          
        assert.equal(data[3].toNumber(),3e18);
    });
    it("correct balance after requesting premium #3", async () => { 
        await instance.requestPremium(0,1539586800);    
        data = await instance.getInfo.call(0);       
        assert.equal(data[3].toNumber(),3e18);
    });
    it("correct balance after requesting premium #4", async () => { 
        await instance.requestPremium(0,1539759600);    
        data = await instance.getInfo.call(0);       
        assert.equal(data[3].toNumber(),2e18);
    });
    it("correct balance after requesting premium #5", async () => { 
        await instance.requestPremium(0,1540278000);    
        data = await instance.getInfo.call(0);          
        assert.equal(data[3].toNumber(),1e18);
    });
    it("correct balance after requesting premium #6", async () => { 
        await instance.requestPremium(0,1540882800);    
        data = await instance.getInfo.call(0);          
        assert.equal(data[3].toNumber(),1e18);
    });
    it("correct balance after requesting premium #7", async () => { 
        await instance.requestPremium(0,1541487600);    
        data = await instance.getInfo.call(0);          
        assert.equal(data[3].toNumber(),"0");
        assert.equal(2,data[6].toNumber());
    });
    it("Should create new CDSorder", async () => {
        instance = await cdpcds.deployed();
        await instance.makeCDSOrder(1000000000000000000,{from: a3, value: 10000000000000000000});
        data = await instance.getInfo.call(1);
        assert.equal(a3,data[0]);
        assert.equal(0,data[6].toNumber());       
    });
    it("Should fill CDSorder", async () => { 
        await instance.fillCDSOrder(1,1539068400,{value:3000000000000000000,from: a4});
        data = await instance.getInfo.call(1);  
        assert.equal(a4,data[2]);
        assert.equal(1,data[6].toNumber());
        });
    it("correct balance after requesting premium  #8", async () => { 
        await instance.requestPremium(1,1539759600);    
        data = await instance.getInfo.call(1);  
        assert.equal(data[3].toNumber(),"2000000000000000000");
        assert.equal(finalBalance,web3.eth.getBalance(a2).toNumber());
    });
})
//TEST 2
//deploy new contract.
// contract('Testing CDPCDS', async (accounts) => {
//     it("Should deploy new conract and create CDP", async () => {
//         instance = await cdpcds.deployed();
//         await instance.makeCDSOrder(1000000000000000000,{from: a1, value: 10000000000000000000});
//         let data;
//         let strcheck;
//         data = await instance.getInfo.call(0);
//         assert.equal(a1,data[0]);
   
//     });
//     it("Should fill CDSOrder", async () => { 
//         let data;
//         let strcheck;
//         await instance.fillCDSOrder(0,1539068400,{value:3000000000000000000,from: a2});
//         data = await instance.getInfo.call(0);  
//         assert.equal(a2,data[2]);
//     });
//     it("correct close outcome", async () => { 
//         let data;
//         let strcheck;
//         await instance.close(0,1539759600);    
//         data = await instance.getInfo.call(0);  
//         strcheck = ""+data[3];
//         assert.equal(strcheck,"no");
//     });
// })
    //TEST 3
    //new contract
// contract('Testing CDPCDS', async (accounts) => {
//     it("Should deploy new conract and create CDP", async () => {
//         instance = await cdpcds.deployed();
//         await instance.makeCDSOrder(1000000000000000000,{from: a1, value: 10000000000000000000});
//         let data;
//         let strcheck;
//         data = await instance.getInfo.call(0);
//         assert.equal(a1,data[0]);       
//     });
//     it("Should fill CDP", async () => { 
//         let data;
//         let strcheck;
//         await instance.fillCDSOrder(0,1539068400,{value:3000000000000000000,from: a2});
//         data = await instance.getInfo.call(0);  
//         assert.equal(a2,data[2]);
//         });
//     it("correct balance after requesting premium  #1", async () => { 
//         let data;
//         let strcheck;
//         await instance.requestPremium(0,1539759600);    
//         data = await instance.getInfo.call(0);  
//         strcheck = ""+data[3];
//         assert.equal(strcheck,"2000000000000000000");
//     });
//     it("correct close outcome", async () => { 
//         let data;
//         let strcheck;
//         await instance.close(0,1541487600);    
//         data = await instance.getInfo.call(0);  
//         strcheck = ""+data[3];
//         assert.equal(strcheck,"no");
//     });
// })

    //TEST 4
    //new contract
// contract('Testing CDPCDS', async (accounts) => {
//     it("Should deploy new conract and create CDP", async () => {
//         instance = await cdpcds.deployed();
//         await instance.makeCDSOrder(1000000000000000000,{from: a1, value: 10000000000000000000});
//         let data;
//         let strcheck;
//         data = await instance.getInfo.call(0);
//         assert.equal(a1,data[0]);       
//     });
//     it("Should fill CDP", async () => { 
//         let data;
//         let strcheck;
//         await instance.fillCDSOrder(0,1539068400,{value:3000000000000000000,from: a2});
//         data = await instance.getInfo.call(0);  
//         assert.equal(a2,data[2]);
//         });
//     it("correct balance after requesting premium  #1", async () => { 
//         let data;
//         let strcheck;
//         await instance.requestPremium(0,1539759600);    
//         data = await instance.getInfo.call(0);  
//         strcheck = ""+data[3];
//         assert.equal(strcheck,"2000000000000000000");
//     });
//     it("correct close outcome", async () => { 
//         let data;
//         let strcheck;
//         await instance.close(0,1541487600);    
//         data = await instance.getInfo.call(0);  
//         strcheck = ""+data[3];
//         assert.equal(strcheck,"no");
//     });
// })   
    

//test1a
//deploy from a0
//makeCDSOrder(1000000000000000000,{val:10000000000000000000,from:a1}) --> mkr b,c (-1e19,1e19) | tkr b,c (0,0)
// --> status: 0
//fillCDSOrder(0,1539068400,{val:3000000000000000000,from:a2}) --> mkr b,c (-1e19,1e19) | tkr b,c (-3e18,3e18)
// --> status: 1
//requestPremium(0,1539154800)  1 --> mkr b,c (-1e19,1e19) | tkr b,c (-3e18,3e18)
//requestPremium(0,1539327600)  3 --> mkr b,c (-1e19,1e19) | tkr b,c (-3e18,3e18)
//requestPremium(0,1539586800)  6 --> mkr b,c (-1e19,1e19) | tkr b,c (-3e18,3e18)
//requestPremium(0,1539759600)  8 --> mkr b,c (-9e18,1e19) | tkr b,c (-3e18,2e18)
//requestPremium(0,1540278000)  14 --> mkr b,c (-8e18,1e19) | tkr b,c (-3e18,1e18)
//requestPremium(0,1540882800)  23 --> mkr b,c (-8e18,1e19) | tkr b,c (-3e18,1e18)
//requestPremium(0,1541487600)  28 --> mkr b,c (-8e18,1e19) | tkr b,c (-3e18,0e18) --> mkr b,c (1.8e19,0) | tkr b,c (-3e18,0e18)
// --> status: 2
//test1b
//makeCDSOrder(1000000000000000000,{val:10000000000000000000,from:a3})
// --> status: 0
//fillCDSOrder(1,1539068400,{val:3000000000000000000,from:a4})
// --> status: 1
// --> mkr b,c (-1e19,1e19) | tkr b,c (-3e18,3e18)
//requestPremium(1,1539759600)
// --> mkr b,c (-9e18,1e19) | tkr b,c (-3e18,2e18)
//close(1,1539759600,{from:a3})
// --> mkr b,c (-3e17,0) | tkr b,c (3e17,0)

//test2

//deploy from a0
//makeCDSOrder(1000000000000000000,{val:10000000000000000000,from:a1})
//fillCDSOrder(0,1539068400,{val:3000000000000000000,from:a2})
//requestPremium(0,1539759600)
//close(0,1539759600)

//test3 

//deploy from a0
//makeCDSOrder(1000000000000000000,{val:10000000000000000000,from:a1})
//fillCDSOrder(0,1539068400,{val:3000000000000000000,from:a2})
//requestPremium(0,1539759600)
//close(0,1541487600)

//test4 

//deploy from a0
//makeCDSOrder(1000000000000000000,{val:10000000000000000000,from:a1})
//fillCDSOrder(0,1539068400,{val:3000000000000000000,from:a2})
//requestPremium(0,1541487600)
//close(0,1541487600)