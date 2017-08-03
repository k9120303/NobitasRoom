<%@ page language="java" contentType="text/html; charset=utf-8"
    pageEncoding="utf-8"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />

        <title>Babylon.js sample code</title>
        <style>
            html, body {
                overflow: hidden;
                width: 100%;
                height: 100%;
                margin: 0;
                padding: 0;
            }

            #renderCanvas {
                width: 100%;
                height: 100%;
                touch-action: none;
            }
			.onHand{
				position:position:absolute;
				float:right;
				top:0px;right:0px;
				width:150px;
				height:150px;
			}
			.queue1{
				position:position:absolute;
				float:right;
				top:150px;right:0px;
				width:100px;
				height:100px;
			}
			.queue2{
				position:position:absolute;
				float:right;
				top:250px;right:0px;
				width:100px;
				height:100px;
			}
			p{
				font-family:微軟正黑體;
				font-size:25px;
				text-align:right;
			}

            .btn{
                font-family: 微軟正黑體;
                position: absolute;
                left: 10%;
                top: 30%;
                transform: translate(-50%, -50%);
                z-index:10;
                border-radius:10px;
                font-size:15px;
            }

            .btn1{
                position: relative;
                color: rgba(255, 255, 255, 1);
                text-decoration: none;
                background-color: rgba(219, 87, 51, 1);
                font-family: 'Yanone Kaffeesatz';
                font-weight: 600;
                font-size: 2em;
                display: block;
                padding: 4px;
                border-radius: 8px;
                /* let's use box shadows to make the button look more 3-dimensional */
                box-shadow: 0px 9px 0px rgba(219, 31, 5, 1), 0px 9px 25px rgba(0, 0, 0, .7);
                margin: 100px auto;
                width: 160px;
                text-align: center;
                -webkit-transition: all .1s ease;
                -moz-transition: all .1s ease;
                transition: all .1s ease;
            }

            /* now if we make the box shadows smaller when the button is clicked, it'll look like the button has been "pushed" */

            .btn1:active{
                box-shadow: 0px 3px 0px rgba(219, 31, 5, 1), 0px 3px 6px rgba(0, 0, 0, .9);
                position: relative;
                top: 6px;
            }
        </style>
    </head>
<body>
    <div id="canvasZone">
        <canvas id="renderCanvas"></canvas>
    </div>
	<div  id="BaiBaoDie" style = "position:absolute;top:0px;right:0px;">
		<p>百寶袋</p>
		<img id = "q0" src="BaiBaoDie/blank.PNG" class="onHand"/>
		<br>
		<img id = "q1" src="BaiBaoDie/blank.PNG"  class="queue1"/>
		<br>
		<img id = "q2" src="BaiBaoDie/blank.PNG"  class="queue2"/>
	</div>

    <div class="btn" id="btn">
        <a href="index.jsp" class="btn1">回首頁</a>
        <a href="doraemon.jsp" class="btn1">重新開始</a>
    </div>

    <script src="script/babylon.js/babylon.3.0.alpha.js"></script>
	<script src="script/babylon.js/hand.minified-1.2.js"></script>
	<script src="script/babylon.js/babylon.js"></script>
	<script src="script/babylon.js/oimo.js"></script>
	<script src="script/babylon.js/cannon.js"></script>
    <script src="script/LoadObjFiles/objFileLoader/babylon.objFileLoader.js"></script>
    <script src="script/LoadObjFiles/loadObjModule.js"></script>
	<script src="script/control/animation.js"></script>
    <script src="script/control/object.js"></script>
	<script src="https://ajax.googleapis.com/ajax/libs/jquery/2.1.1/jquery.min.js"></script>
        <script src="script/Physics/Plugins/babylon.oimoJSPlugin.js"></script>
    <script>
        var booksArray = [];
        var bookCaseArray = []
        var canvas = document.getElementById("renderCanvas");
		
        var engine = new BABYLON.Engine(canvas, true);

		// This creates a basic Babylon Scene object (non-mesh)
        var scene = new BABYLON.Scene(engine);

		// This creates and positions a free camera (non-mesh)
        var camera = new BABYLON.FreeCamera("camera1", new BABYLON.Vector3(0, 10, -10), scene);
		//var camera = new BABYLON.ArcRotateCamera("Camera", 0, 0, 10, new BABYLON.Vector3(100, 5, -100), scene);
		
		var inScreen = false;
		
		var name;
		
		var BaiBaoDie = [];
		
		var BBDIndex = 0;
		
		var objList = [];
		var others = [];
		var objParent = [];
		
		var origin = [];//存 obj 初始狀態
		
		var counter = 0;//紀錄何時可以開始
		
		var chair,lamp,desk;
		
		var rightGroup = createRightHand(camera, scene);
		
        var createScene = function () {

			scene.actionManager = new BABYLON.ActionManager(scene);
            scene.enablePhysics(new BABYLON.Vector3(0, -10, 0), new BABYLON.OimoJSPlugin());
            // This targets the camera to scene origin
            camera.setTarget(BABYLON.Vector3.Zero());
            var music = new BABYLON.Sound("Violons", "sounds/bgm.wav", scene,
                null, { loop: true, autoplay: true }
            );
            // This attaches the camera to the canvas
            camera.attachControl(canvas, true);
			
			initPointerLock(scene,camera);
			
			//設上下左右為w,a,s,d
			camera.keysUp.push(87); // "w"
			camera.keysRight.push(68);//d
			camera.keysLeft.push(65);//a
			camera.keysDown.push(83); // "s"

            var light = new BABYLON.HemisphericLight("light1", new BABYLON.Vector3(2, 2, 1), scene);
            light.groundColor = new BABYLON.Color3(1, 1, 1);
            light.intensity = 0.5;
			
			/*
			//黑色材質
			var black = new BABYLON.StandardMaterial('black', scene);
			black.diffuseColor = new BABYLON.Color3(0, 0, 0);
			
			var green = new BABYLON.StandardMaterial('green', scene);
			green.diffuseColor = new BABYLON.Color3(0, 1, 0);
			green.emissiveColor = BABYLON.Color3.Green();
			*/
			
			var leftGroup = createLeftHand(camera, scene);
			//var rightGroup = createRightHand(camera, scene);
			var aim = createAim(camera, scene);
			aim.isPickable = false;	
			var aim2 = createAim2(camera, scene);
			aim2.isPickable = false;	
			
			
			//--------------------------------------
			
			var loader = new BABYLON.AssetsManager(scene);

            var returnDatas= loadObj(scene,"scene","ItemModels/room/","roomSceme.obj",{x:5,y:0,z:0},{x:1,y:1,z:1},{x:0,y:Math.PI/100,z:0});
            console.log(returnDatas);
			scene = returnDatas["scene"];
            returnDatas["object"].checkCollisions = true;
            returnDatas["object"].applyGravity = true;
			console.log(returnDatas["object"]);


            returnDatas = loadObj(scene,"window","ItemModels/window/","window.obj",{x:40,y:0,z:60},{x:0.8,y:0.5,z:0.8},{x:0,y:Math.PI/100,z:0})
            scene = returnDatas["scene"]
            others.push(returnDatas["object"]);

            var roofTop = createSingleRect(scene,"RoofTop",{x:10,y:70,z:10},{x:20,y:0.6,z:20},{x:-Math.PI/45,y:Math.PI/60,z:Math.PI},"ItemModels/room/roofTop.jpeg",{u:5.0,v:5.0}).box;
            createSingleRect(scene,"door",{x:96,y:5,z:-17},{x:7,y:8,z:0.01},{x:-Math.PI  ,y:-Math.PI/2 + Math.PI/34 + Math.PI/4444 ,z:Math.PI- Math.PI/100 - Math.PI/44 + Math.PI/100},"ItemModels/room/door.jpg",{u:1.0,v:1.0})

            returnDatas = loadObj(scene,"chair","ItemModels/chair/","chair.obj",{x:70,y:-20,z:20},{x:0.5,y:0.5,z:0.5},{x:0,y:Math.PI/100,z:0})  //椅子
            scene = returnDatas["scene"]
            chair = returnDatas["object"]
			origin.push({scaleX:0.5,scaleY:0.5,scaleZ:0.5,posX:70,posY:-20,posZ:20});
            returnDatas = loadObj(scene,"lamp","ItemModels/lamp/lamp/","lamp.obj",{x:45,y:0,z:40},{x:0.2,y:0.2,z:0.2},{x:0,y:Math.PI/1.5,z:0}) //檯燈
            scene = returnDatas["scene"]
            lamp = returnDatas["object"]
			origin.push({scaleX:0.2,scaleY:0.2,scaleZ:0.2,posX:45,posY:0,posZ:40});
            
			returnDatas = loadObj(scene,"desk","ItemModels/desk/desk/","desk.obj",{x:64,y:-32.5,z:40},{x:0.35,y:0.35,z:0.35},{x:0,y:-Math.PI/2,z:0}) //書桌
            scene = returnDatas["scene"]
            desk = returnDatas["object"]
			origin.push({scaleX:0.35,scaleY:0.35,scaleZ:0.35,posX:64,posY:-32.5,posZ:40});

            returnDatas = loadObj(scene,"bookcase","ItemModels/bookcase/","bookcase.obj",{x:-34,y:-32,z:-55},{x:0.65,y:0.69,z:0.65},{x:0,y:Math.PI/1.9,z:-Math.PI/68}) //大書櫃
            scene = returnDatas["scene"]
            bookCaseArray.push(returnDatas["object"]);
            returnDatas = loadObj(scene,"bookcase2","ItemModels/bookcase2/","bookcase2.obj",{x:-40,y:-25,z:62},{x:0.4,y:0.4,z:0.4},{x:0,y:Math.PI/1.9,z:-Math.PI/68}) //藍色小櫃子
            scene = returnDatas["scene"]
            bookCaseArray.push(returnDatas["object"]);
            returnDatas = loadObj(scene,"droplight","ItemModels/droplight/","droplight.obj",{x:17,y:45,z:-15},{x:0.35,y:0.35,z:0.35},{x:0,y:Math.PI/1.95,z:-Math.PI/68}) //吊燈
            scene = returnDatas["scene"]
            bookCaseArray.push(returnDatas["object"]);
            //書櫃第一層

            returnDatas = loadObj(scene,"book1","ItemModels/book/","RedBook.obj",{x:-38.2,y:-10.9,z:-64.8},{x:0.7,y:0.82,z:1},{x:0,y:Math.PI/1.9,z:-Math.PI/68})
            scene = returnDatas["scene"]
            booksArray.push(returnDatas["object"]);
            returnDatas = loadObj(scene,"book2","ItemModels/book/","BlueBook.obj",{x:-37.9,y:-10.7,z:-59.2},{x:1,y:0.82,z:1},{x:0,y:Math.PI/1.9,z:-Math.PI/68})
            scene = returnDatas["scene"]
            booksArray.push(returnDatas["object"]);
            returnDatas = loadObj(scene,"book3","ItemModels/book/","GreenBook.obj",{x:-37.8,y:-10.6,z:-57.1},{x:1,y:0.82,z:1},{x:0,y:Math.PI/1.9,z:-Math.PI/68})
            scene = returnDatas["scene"]
            booksArray.push(returnDatas["object"]);
            returnDatas = loadObj(scene,"book19","ItemModels/book/","BlueBook.obj",{x:-37.7,y:-10.5,z:-55},{x:1,y:0.82,z:1},{x:0,y:Math.PI/1.9,z:-Math.PI/68})
            scene = returnDatas["scene"]
            booksArray.push(returnDatas["object"]);
            returnDatas = loadObj(scene,"book4","ItemModels/book/","YellowBook.obj",{x:-37.6,y:-10.4,z:-52.9},{x:1,y:0.8,z:1},{x:0,y:Math.PI/1.9,z:-Math.PI/68})
            scene = returnDatas["scene"]
            booksArray.push(returnDatas["object"]);
            returnDatas = loadObj(scene,"book5","ItemModels/book/","BlueBook.obj",{x:-37.5,y:-10.3,z:-50.8},{x:1,y:0.79,z:1},{x:0,y:Math.PI/1.9,z:-Math.PI/68})
            scene = returnDatas["scene"]
            booksArray.push(returnDatas["object"]);
            returnDatas = loadObj(scene,"book6","ItemModels/book/","RedBook.obj",{x:-37.4,y:-10.2,z:-48.7},{x:1,y:0.77,z:1},{x:0,y:Math.PI/1.9,z:-Math.PI/68})
            scene = returnDatas["scene"]
            booksArray.push(returnDatas["object"]);
            returnDatas = loadObj(scene,"book7","ItemModels/book/","BlueBook.obj",{x:-37.3,y:-10.1,z:-46.6},{x:1,y:0.78,z:1},{x:0,y:Math.PI/1.9,z:-Math.PI/68})
            scene = returnDatas["scene"]
            booksArray.push(returnDatas["object"]);
            returnDatas = loadObj(scene,"book8","ItemModels/book/","GreenBook.obj",{x:-37.2,y:-10,z:-44.5},{x:1,y:0.79,z:1},{x:0,y:Math.PI/1.9,z:-Math.PI/68})
            scene = returnDatas["scene"]
            booksArray.push(returnDatas["object"]);
            returnDatas = loadObj(scene,"book9","ItemModels/book/","RedBook.obj",{x:-37.1,y:-9.9,z:-42.4},{x:1,y:0.78,z:1},{x:0,y:Math.PI/1.9,z:-Math.PI/68})
            scene = returnDatas["scene"]
            booksArray.push(returnDatas["object"]);
            returnDatas = loadObj(scene,"book10","ItemModels/book/","OrangeBook.obj",{x:-37,y:-9.8,z:-40.3},{x:1,y:0.8,z:1},{x:0,y:Math.PI/1.9,z:-Math.PI/68})
            scene = returnDatas["scene"]
            booksArray.push(returnDatas["object"]);
            returnDatas = loadObj(scene,"book11","ItemModels/book/","BlueBook.obj",{x:-36.9,y:-9.7,z:-38.2},{x:1,y:0.75,z:1},{x:0,y:Math.PI/1.9,z:-Math.PI/68})
            scene = returnDatas["scene"]
            booksArray.push(returnDatas["object"]);
            returnDatas = loadObj(scene,"book12","ItemModels/book/","BlueBook.obj",{x:-36.8,y:-9.6,z:-36.1},{x:1,y:0.69,z:1},{x:0,y:Math.PI/1.9,z:-Math.PI/68})
            scene = returnDatas["scene"]
            booksArray.push(returnDatas["object"]);
            returnDatas = loadObj(scene,"book13","ItemModels/book/","BlueBook.obj",{x:-36.7,y:-9.5,z:-34},{x:1,y:0.7,z:1},{x:0,y:Math.PI/1.9,z:-Math.PI/68})
            scene = returnDatas["scene"]
            booksArray.push(returnDatas["object"]);
            returnDatas = loadObj(scene,"book14","ItemModels/book/","BlueBook.obj",{x:-36.6,y:-9.4,z:-31.9},{x:1,y:0.69,z:1},{x:0,y:Math.PI/1.9,z:-Math.PI/68})
            scene = returnDatas["scene"]
            booksArray.push(returnDatas["object"]);
            returnDatas = loadObj(scene,"book15","ItemModels/book/","OrangeBook.obj",{x:-36.5,y:-9.3,z:-29.8},{x:1,y:0.69,z:1},{x:0,y:Math.PI/1.9,z:-Math.PI/68})
            scene = returnDatas["scene"]
            booksArray.push(returnDatas["object"]);
            returnDatas = loadObj(scene,"book16","ItemModels/book/","YellowBook.obj",{x:-36.4,y:-9.2,z:-27.7},{x:1,y:0.75,z:1},{x:0,y:Math.PI/1.9,z:-Math.PI/68})
            scene = returnDatas["scene"]
            booksArray.push(returnDatas["object"]);
            returnDatas = loadObj(scene,"book17","ItemModels/book/","BlueBook.obj",{x:-36.3,y:-9.1,z:-25.6},{x:1,y:0.73,z:1},{x:0,y:Math.PI/1.9,z:-Math.PI/68})
            scene = returnDatas["scene"]
            booksArray.push(returnDatas["object"]);
            returnDatas = loadObj(scene,"book18","ItemModels/book/","BlueBook.obj",{x:-36.2,y:-9,z:-23.5},{x:1,y:0.75,z:1},{x:0,y:Math.PI/1.9,z:-Math.PI/68})
            scene = returnDatas["scene"]
            booksArray.push(returnDatas["object"]);

            //書櫃第二層

            returnDatas = loadObj(scene,"2book1","ItemModels/book/","BlueBook.obj",{x:-38,y:7.8,z:-61.5},{x:1,y:0.73,z:1},{x:0,y:Math.PI/1.9,z:-Math.PI/68})
            scene = returnDatas["scene"]
            booksArray.push(returnDatas["object"]);
            returnDatas = loadObj(scene,"2book2","ItemModels/book/","BlueBook.obj",{x:-37.9,y:7.9,z:-59.2},{x:1,y:0.72,z:1},{x:0,y:Math.PI/1.9,z:-Math.PI/68})
            scene = returnDatas["scene"]
            booksArray.push(returnDatas["object"]);
            returnDatas = loadObj(scene,"2book3","ItemModels/book/","GreenBook.obj",{x:-37.8,y:8,z:-57.1},{x:1,y:0.73,z:1},{x:0,y:Math.PI/1.9,z:-Math.PI/68})
            scene = returnDatas["scene"]
            booksArray.push(returnDatas["object"]);
            returnDatas = loadObj(scene,"2book13","ItemModels/book/","OrangeBook.obj",{x:-37.7,y:8.1,z:-55},{x:1,y:0.74,z:1},{x:0,y:Math.PI/1.9,z:-Math.PI/68})
            scene = returnDatas["scene"]
            booksArray.push(returnDatas["object"]);
            returnDatas = loadObj(scene,"2book4","ItemModels/book/","OrangeBook.obj",{x:-37.6,y:8.2,z:-52.9},{x:1,y:0.72,z:1},{x:0,y:Math.PI/1.9,z:-Math.PI/68})
            scene = returnDatas["scene"]
            booksArray.push(returnDatas["object"]);
            returnDatas = loadObj(scene,"2book5","ItemModels/book/","GreenBook.obj",{x:-37.5,y:8.3,z:-50.8},{x:1,y:0.7,z:1},{x:0,y:Math.PI/1.9,z:-Math.PI/68})
            scene = returnDatas["scene"]
            booksArray.push(returnDatas["object"]);
            returnDatas = loadObj(scene,"2book6","ItemModels/book/","RedBook.obj",{x:-37.4,y:8.4,z:-48.7},{x:1,y:0.69,z:1},{x:0,y:Math.PI/1.9,z:-Math.PI/68})
            scene = returnDatas["scene"]
            booksArray.push(returnDatas["object"]);
            returnDatas = loadObj(scene,"2book7","ItemModels/book/","BlueBook.obj",{x:-37.3,y:8.5,z:-46.6},{x:1,y:0.69,z:1},{x:0,y:Math.PI/1.9,z:-Math.PI/68})
            scene = returnDatas["scene"]
            booksArray.push(returnDatas["object"]);
            returnDatas = loadObj(scene,"2book8","ItemModels/book/","GreenBook.obj",{x:-37.2,y:8.6,z:-44.5},{x:1,y:0.69,z:1},{x:0,y:Math.PI/1.9,z:-Math.PI/68})
            scene = returnDatas["scene"]
            booksArray.push(returnDatas["object"]);
            returnDatas = loadObj(scene,"2book9","ItemModels/book/","RedBook.obj",{x:-37.1,y:8.7,z:-42.4},{x:1,y:0.72,z:1},{x:0,y:Math.PI/1.9,z:-Math.PI/68})
            scene = returnDatas["scene"]
            booksArray.push(returnDatas["object"]);
            returnDatas = loadObj(scene,"2book10","ItemModels/book/","BlueBook.obj",{x:-37,y:8.8,z:-40.3},{x:1,y:0.71,z:1},{x:0,y:Math.PI/1.9,z:-Math.PI/68})
            scene = returnDatas["scene"]
            booksArray.push(returnDatas["object"]);
            returnDatas = loadObj(scene,"2book11","ItemModels/book/","BlueBook.obj",{x:-36.9,y:8.9,z:-38.2},{x:1,y:0.72,z:1},{x:0,y:Math.PI/1.9,z:-Math.PI/68})
            scene = returnDatas["scene"]
            booksArray.push(returnDatas["object"]);
            returnDatas = loadObj(scene,"2book12","ItemModels/book/","YellowBook.obj",{x:-36.8,y:9,z:-36.1},{x:1,y:0.72,z:1},{x:0,y:Math.PI/1.9,z:-Math.PI/68})
            scene = returnDatas["scene"]
            booksArray.push(returnDatas["object"]);



            //書櫃第三層

            scene = returnDatas["scene"]
            returnDatas = loadObj(scene,"3book4","ItemModels/book/","OrangeBook.obj",{x:-36.6,y:22.9,z:-52.9},{x:1,y:0.7,z:1},{x:0,y:Math.PI/1.9,z:-Math.PI/68})
            scene = returnDatas["scene"]
            booksArray.push(returnDatas["object"]);
            returnDatas = loadObj(scene,"3book5","ItemModels/book/","OrangeBook.obj",{x:-36.5,y:23,z:-50.8},{x:1,y:0.72,z:1},{x:0,y:Math.PI/1.9,z:-Math.PI/68})
            scene = returnDatas["scene"]
            booksArray.push(returnDatas["object"]);
            returnDatas = loadObj(scene,"3book6","ItemModels/book/","GreenBook.obj",{x:-36.4,y:23.1,z:-48.7},{x:1,y:0.71,z:1},{x:0,y:Math.PI/1.9,z:-Math.PI/68})
            scene = returnDatas["scene"]
            booksArray.push(returnDatas["object"]);
            returnDatas = loadObj(scene,"3book7","ItemModels/book/","BlueBook.obj",{x:-36.3,y:23.2,z:-46.6},{x:1,y:0.69,z:1},{x:0,y:Math.PI/1.9,z:-Math.PI/68})
            scene = returnDatas["scene"]
            booksArray.push(returnDatas["object"]);
            returnDatas = loadObj(scene,"3book8","ItemModels/book/","GreenBook.obj",{x:-36.2,y:23.3,z:-44.5},{x:1,y:0.68,z:1},{x:0,y:Math.PI/1.9,z:-Math.PI/68})
            scene = returnDatas["scene"]
            booksArray.push(returnDatas["object"]);
            returnDatas = loadObj(scene,"3book9","ItemModels/book/","GreenBook.obj",{x:-36.1,y:23.4,z:-42.4},{x:1,y:0.68,z:1},{x:0,y:Math.PI/1.9,z:-Math.PI/68})
            scene = returnDatas["scene"]
            booksArray.push(returnDatas["object"]);
            returnDatas = loadObj(scene,"3book10","ItemModels/book/","RedBook.obj",{x:-36,y:23.5,z:-40.3},{x:1,y:0.68,z:1},{x:0,y:Math.PI/1.9,z:-Math.PI/68})
            scene = returnDatas["scene"]
            booksArray.push(returnDatas["object"]);
            returnDatas = loadObj(scene,"3book11","ItemModels/book/","YellowBook.obj",{x:-35.9,y:23.6,z:-38.2},{x:1,y:0.68,z:1},{x:0,y:Math.PI/1.9,z:-Math.PI/68})
            scene = returnDatas["scene"]
            booksArray.push(returnDatas["object"]);
            returnDatas = loadObj(scene,"3book12","ItemModels/book/","BlueBook.obj",{x:-35.8,y:23.7,z:-36.1},{x:1,y:0.69,z:1},{x:0,y:Math.PI/1.9,z:-Math.PI/68})
            scene = returnDatas["scene"]
            booksArray.push(returnDatas["object"]);
            returnDatas = loadObj(scene,"3book13","ItemModels/book/","GreenBook.obj",{x:-35.7,y:23.8,z:-34},{x:1,y:0.7,z:1},{x:0,y:Math.PI/1.9,z:-Math.PI/68})
            scene = returnDatas["scene"]
            booksArray.push(returnDatas["object"]);
            returnDatas = loadObj(scene,"3book14","ItemModels/book/","BlueBook.obj",{x:-35.6,y:23.9,z:-31.9},{x:1,y:0.67,z:1},{x:0,y:Math.PI/1.9,z:-Math.PI/68})
            scene = returnDatas["scene"]
            booksArray.push(returnDatas["object"]);
            returnDatas = loadObj(scene,"3book15","ItemModels/book/","BlueBook.obj",{x:-35.5,y:24,z:-29.8},{x:1,y:0.67,z:1},{x:0,y:Math.PI/1.9,z:-Math.PI/68})
            scene = returnDatas["scene"]
            booksArray.push(returnDatas["object"]);
            returnDatas = loadObj(scene,"3book16","ItemModels/book/","BlueBook.obj",{x:-35.4,y:24.1,z:-27.7},{x:1,y:0.67,z:1},{x:0,y:Math.PI/1.9,z:-Math.PI/68})
            scene = returnDatas["scene"]
            booksArray.push(returnDatas["object"]);
            returnDatas = loadObj(scene,"3book17","ItemModels/book/","RedBook.obj",{x:-35.3,y:24.2,z:-25.6},{x:1,y:0.70,z:1},{x:0,y:Math.PI/1.9,z:-Math.PI/68})
            scene = returnDatas["scene"]
            booksArray.push(returnDatas["object"]);
            returnDatas = loadObj(scene,"3book18","ItemModels/book/","RedBook.obj",{x:-35.2,y:24.3,z:-23.5},{x:1,y:0.71,z:1},{x:0,y:Math.PI/1.9,z:-Math.PI/68})
            scene = returnDatas["scene"]

            booksArray.push(returnDatas["object"]);
            //-------------------------很臭的code ---------------------------------------------------------
            returnDatas = loadObj(scene,"penguin1","ItemModels/penguin/","Penguin.obj",{x:-36.8,y:9,z:-40.1},{x:0.1,y:0.1,z:0.1},{x:0,y:0,z:-Math.PI/68})
            scene = returnDatas["scene"]
            others.push(returnDatas["object"]);
            returnDatas = loadObj(scene,"penguin2","ItemModels/penguin/","Penguin.obj",{x:72,y:2,z:50},{x:0.1,y:0.1,z:0.1},{x:0,y:0,z:-Math.PI/68})
            scene = returnDatas["scene"];
            others.push(returnDatas["object"]);
            returnDatas = loadObj(scene,"penguin3","ItemModels/penguin/","Penguin.obj",{x:-42,y:3.5,z:63},{x:0.1,y:0.1,z:0.1},{x:0,y:-Math.PI/1.9,z:-Math.PI/68})
            scene = returnDatas["scene"]
            others.push(returnDatas["object"]);
            returnDatas = loadObj(scene,"tank","ItemModels/tank/","tank.obj",{x:66,y:2,z:50},{x:0.1,y:0.1,z:0.1},{x:-Math.PI/90,y:0,z:-Math.PI/68})
            scene = returnDatas["scene"]
            others.push(returnDatas["object"]);
            returnDatas = loadObj(scene,"tank2","ItemModels/tank/","tank.obj",{x:-36.6,y:22.9,z:-72},{x:0.1,y:0.1,z:0.1},{x:Math.PI/90,y:-Math.PI/2.1,z:-Math.PI/90})
            scene = returnDatas["scene"]
            others.push(returnDatas["object"]);
            returnDatas = loadObj(scene,"cup","ItemModels/cup/","cup.obj",{x:91,y:2,z:26},{x:0.1,y:0.1,z:0.1},{x:-Math.PI/90,y:0,z:0})
            scene = returnDatas["scene"];
            others.push(returnDatas["object"]);
            returnDatas = loadObj(scene,"clock","ItemModels/clock/","clock.obj",{x:17,y:25,z:-82},{x:0.6,y:0.6,z:0.6},{x:Math.PI/2.1,y:-Math.PI/2.1,z:-Math.PI/1.98});
            scene = returnDatas["scene"];
            others.push(returnDatas["object"]);
            /*
                for(var i=0;i<booksArray.length;i++){
                    console.log("Now is "+i);
                    console.log(booksArray[i])
                    //origin.push({scaleX:0.35,scaleY:0.35,scaleZ:0.35,posX:64,posY:-32.5,posZ:40});
                    var tempScaling = booksArray[i].loadedMeshes[0].scaling;
                    var tempPosition = booksArray[i].loadedMeshes[0].position;
                    origin.push({
                        scaleX: tempScaling.x,
                        scaleY: tempScaling.y,
                        scaleZ: tempScaling.z,
                        posX: tempPosition.x,
                        posY: tempPosition.y,
                        posZ: tempPosition.z
                    })
                }*/


            //console.log(booksArray)
            createSingleRect(scene,"bath",{x:40,y:20,z:61},{x:4,y:0.1,z:5},{x:Math.PI/300,y:Math.PI/2,z:Math.PI/2},"ItemModels/bath.jpg",{u:1.0,v:1.0})
            createSingleRect(scene,"RoofTop",{x:10,y:70,z:10},{x:20,y:0.6,z:20},{x:-Math.PI/45,y:Math.PI/60,z:Math.PI},"ItemModels/room/roofTop.jpeg",{u:5.0,v:5.0})
            createSingleRect(scene,"door",{x:96,y:5,z:-17},{x:7,y:8,z:0.01},{x:-Math.PI  ,y:-Math.PI/2 + Math.PI/34 + Math.PI/4444 ,z:Math.PI- Math.PI/100 - Math.PI/44 + Math.PI/100},"ItemModels/room/door.jpg",{u:1.0,v:1.0})
            var floor = createSingleRect(scene,"floor",{x:10,y:-31,z:-20},{x:50,y:0.05,z:60},{x:-Math.PI/60,y:Math.PI/60,z:-Math.PI/150},"ItemModels/floor.png",{u:5.0,v:5.0}).box;
            floor.physicsImpostor = new BABYLON.PhysicsImpostor(floor, BABYLON.PhysicsImpostor.BoxImpostor, { mass: 0, restitution: 0.9 }, scene);
            console.log("fuck");
            console.log(floor);
            //scene.enablePhysics();
            // Our built-in 'sphere' shape. Params: name, subdivs, size, scene
            var sphere = BABYLON.Mesh.CreateSphere("sphere1", 16, 2, scene);
            console.log("bookArray");
            console.log(booksArray)
            // Move the sphere upward 1/2 its height
            sphere.position.y = 2;
            var meshesColliderList = [];

            sphere.physicsImpostor = new BABYLON.PhysicsImpostor(sphere, BABYLON.PhysicsImpostor.SphereImpostor, { mass: 1, restitution: 0 }, scene);

            scene.collisionsEnabled = true;
            camera.checkCollisions = true;
			scene.constantlyUpdateMeshUnderPointer = true;

			scene.onPointerMove = function (evt) {
				//pickingInfo doesn'T work for some reason, must debug!
				var pickResult = scene.pick(scene.pointerX, scene.pointerY);
				name = "nothing";
				if (pickResult.pickedMesh) {
					var dis = distance(pickResult.pickedMesh);
					var condition = (dis <= 100) ? true : false; 
					if(condition){
						name = pickResult.pickedMesh.name;
					}
				}
				mouseOverOut(objList);
				//console.log(name);
			}
			
			
			//------------------------------------------------------------
            console.log("Scene");
            console.log(scene);
            return scene;
        
        };
		
		function createSingleRect(scene,name,boxPosition,boxScaling,boxRotation,texturePath,scale){
            //texturePath is the image Path of the texture

            var box = BABYLON.Mesh.CreateBox(name,10,scene)
            box.position.x = boxPosition.x
            box.position.y = boxPosition.y
            box.position.z = boxPosition.z
            box.scaling.x = boxScaling.x
            box.scaling.y = boxScaling.y
            box.scaling.z = boxScaling.z
            box.rotation.x = boxRotation.x
            box.rotation.y = boxRotation.y
            box.rotation.z = boxRotation.z
            var texture = new BABYLON.StandardMaterial(name,scene)
            texture.diffuseTexture = new BABYLON.Texture(texturePath,scene)
            texture.diffuseTexture.uScale = scale.u;//Repeat 5 times on the Vertical Axes
            texture.diffuseTexture.vScale = scale.v;//Repeat 5 times on the Horizontal Axes
            texture.backFaceCulling = false;//Always show the front and the back of an element
            box.material = texture
            box.physicsImpostor = new BABYLON.PhysicsImpostor(box, BABYLON.PhysicsImpostor.BoxImpostor, { mass: 0, restitution: 0.9 }, scene);
            return {
                scene:scene,
                box:box
            }
        }
        var booksData = {};
		function loadObj(scene,objname,objPath,obj,position,size,angle){ //position is { x: x , y: y  ,z:z}
            if(obj === "RedBook.obj"){

                booksData[objname] = "Redbook";
                //RedBook.push(objname);
            }
            else if(obj === "BlueBook.obj"){
                booksData[objname] = "Bluebook";
            }
            else if(obj === "OrangeBook.obj"){
                booksData[objname] = "Orangebook";
            }
            else if(obj==="YellowBook.obj"){
                booksData[objname] = "Yellowbook";
            }
            else if(obj==="GreenBook.obj"){
                booksData[objname] = "Greenbook";
            }
			var loader = new BABYLON.AssetsManager(scene);
			BABYLON.OBJFileLoader.OPTIMIZE_WITH_UV = true;
			var pos = function(t) {
				t.loadedMeshes.forEach(function(m) {
					m.position.x = position.x;
					m.position.y = position.y;
					m.position.z = position.z;
					m.scaling.x = size.x;
					m.scaling.y = size.y;
					m.scaling.z = size.z;
					m.rotation.x = angle.x;
					m.rotation.y =angle.y;
					m.rotation.z = angle.z;
					m.checkCollisions = true; //加入碰撞，不可穿越
					m.name = objname;
					
					});
				finishLoad();
			};
			var object = loader.addMeshTask(objname, "", objPath, obj);
			object.onSuccess = pos;
			loader.load();

			return {"scene":scene,"object":object};
		}
		
		
		//等所有物件都載入成功才去call setParent
		function finishLoad(){
		    console.log(counter);
			counter++;
			if(counter >= 62) {
			setParent(objList,objParent);
			console.log("start");
			}
		}

		//讓螢幕跟著滑鼠移動
		function  initPointerLock(scene,camera) {
		
			// Request pointer lock
			var canvas = scene.getEngine().getRenderingCanvas();
			// On click event, request pointer lock
			canvas.addEventListener("click", function(evt) {
				canvas.requestPointerLock = canvas.requestPointerLock || canvas.msRequestPointerLock || canvas.mozRequestPointerLock || canvas.webkitRequestPointerLock;
				if (canvas.requestPointerLock) {
					canvas.requestPointerLock();
				}
			}, false);

			// Event listener when the pointerlock is updated (or removed by pressing ESC for example).
			var pointerlockchange = function (event) {
				var controlEnabled = (
								   document.mozPointerLockElement === canvas
								|| document.webkitPointerLockElement === canvas
								|| document.msPointerLockElement === canvas
								|| document.pointerLockElement === canvas);
				// If the user is alreday locked
				if (! controlEnabled) {
					//camera.detachControl(canvas);
					console.log('The pointer lock status is now locked');
					inScreen = false;
				} else {
					//camera.attachControl(canvas);
					console.log('The pointer lock status is now unlocked'); 
					inScreen = true;
				}
			};

			// Attach events to the document
			document.addEventListener("pointerlockchange", pointerlockchange, false);
			document.addEventListener("mspointerlockchange", pointerlockchange, false);
			document.addEventListener("mozpointerlockchange", pointerlockchange, false);
			document.addEventListener("webkitpointerlockchange", pointerlockchange, false);
		}
		
		
		
		var mouseOverUnit = function(unit_mesh) {
			unit_mesh.source.parent.scaling.x += 0.05;
			unit_mesh.source.parent.scaling.y += 0.05;
			unit_mesh.source.parent.scaling.z += 0.05;
		};

		var mouseOutUnit = function(unit_mesh) {
			unit_mesh.source.parent.scaling.x -= 0.05;
			unit_mesh.source.parent.scaling.y -= 0.05;
			unit_mesh.source.parent.scaling.z -= 0.05;
		};

		function mouseOverOut(objList) {
				
			for(var objIndex = 0; objIndex < objList.length; objIndex++){
				for(var j = 0;j < objList[objIndex].loadedMeshes.length; j++){
					var dis = distance(objList[objIndex].loadedMeshes[j]);
					var condition = new BABYLON.PredicateCondition(objList[objIndex].loadedMeshes[j].actionManager, function () {
						if(dis <= 100){
							return true;
						}else{
							return false;
						}
					});
					
					var action = new BABYLON.ExecuteCodeAction(BABYLON.ActionManager.OnPointerOverTrigger, mouseOverUnit, condition);
					var action2 = new BABYLON.ExecuteCodeAction(BABYLON.ActionManager.OnPointerOutTrigger, mouseOutUnit, condition);
					
					objList[objIndex].loadedMeshes[j].actionManager = new BABYLON.ActionManager(scene);
					objList[objIndex].loadedMeshes[j].actionManager.registerAction(action);
					objList[objIndex].loadedMeshes[j].actionManager.registerAction(action2);
				}
			}	
				
				
		}
		
		function getObjPosByName(name,objParent,camera){
			console.log("infunc");
			var returnObj;
			console.log(name);
			switch(name){
				case objParent[0].getChildren()[0].name:
					returnObj = objParent[0].position;
					break;
				case objParent[1].getChildren()[0].name:
					returnObj = objParent[1].position;
					break;
				case objParent[2].getChildren()[0].name:
					returnObj = objParent[2].position;
					break;
				default:
					returnObj = camera.position;
					break;
			}
			return returnObj;
		}
		
		function setParent(objList,objParent){
			//push obj to objList
			objList.push(chair);
			objList.push(lamp);
			objList.push(desk);
            for(var i=0;i<bookCaseArray.length;i++){
                objList.push(bookCaseArray[i]);
            }
			for(var i=0;i<booksArray.length;i++){

			    objList.push(booksArray[i])
            }
            for(var i=0;i<others.length;i++){
			    objList.push(others[i])
            }

			//-------------------

			console.log("幹你娘機八");
			//紅色材質 for debug
			var red = new BABYLON.StandardMaterial('red', scene);
			red.diffuseColor = new BABYLON.Color3(1, 0, 0);
			red.emissiveColor = BABYLON.Color3.Red();
			
			for(var i = 0;i < objList.length;i++){
				var box = BABYLON.MeshBuilder.CreateBox(objList[i].name + "Parent",{height: 10, width: 10, depth: 10},scene);
				box.position.x = objList[i].loadedMeshes[0].position.x;
				box.position.y = objList[i].loadedMeshes[0].position.y;
				box.position.z = objList[i].loadedMeshes[0].position.z;
				var temp = objList[i].loadedMeshes[0].scaling;
				box.material = red;
				box.isVisible = false;
				//box.isVisible = false;
				for(var j = 0;j < objList[i].loadedMeshes.length;j++){
					objList[i].loadedMeshes[j].parent = box;
					objList[i].loadedMeshes[j].scaling.x = temp.x;
					objList[i].loadedMeshes[j].scaling.y = temp.y;
					objList[i].loadedMeshes[j].scaling.z = temp.z;
					objList[i].loadedMeshes[j].position.x -= box.position.x;
					objList[i].loadedMeshes[j].position.y -= box.position.y;
					objList[i].loadedMeshes[j].position.z -= box.position.z;
					//objList[i].loadedMeshes[j].physicsImpostor = new BABYLON.PhysicsImpostor(objList[i].loadedMeshes[j], BABYLON.PhysicsImpostor.sphereImpostor, { mass: 5, restitution: 0 }, scene);
				}
				objParent.push(box);	
			}

			engine.runRenderLoop(function () {
					if(camera.rotation.y >= Math.PI) camera.rotation.y = Math.PI;
					if(camera.rotation.y <= Math.PI * (-1)) camera.rotation.y = (-1) * Math.PI;
					scene.render();				
			});	
		}
		
		
		
		function distance(mesh){
			var detlaPosition = new BABYLON.Vector3(camera.position.x - mesh.position.x, camera.position.y - mesh.position.y, camera.position.z - mesh.position.z);
			var dis = Math.sqrt(Math.pow(detlaPosition.x,2) + Math.pow(detlaPosition.y,2) + Math.pow(detlaPosition.z,2));
			return dis;
		}
		
		scene = createScene();
		
        // Resize
        window.addEventListener("resize", function () {
            engine.resize();
        });
		
		//limit camera y-position = 5;
		window.addEventListener("keyup", function(e){
			camera.position.y = 10;
		}, false);
		
		//limit camera y-position = 5;
		window.addEventListener("keydown", function(e){
			camera.position.y = 10;
		}, false);
		
		//limit camera y-position = 5;
		window.addEventListener("keyleft", function(e){
			camera.position.y = 10;
		}, false);
		
		//limit camera y-position = 5;
		window.addEventListener("keyright", function(e){
			camera.position.y = 10;
		}, false);
		
		//limit camera y-position = 5;
		
		window.addEventListener("keypress", function(e){
			if(e.keyCode == 32){
				objParent = pick(objList, objParent, camera);			
			}
			
			if(e.keyCode == 106){
		    }	
		}, false);
		
		window.addEventListener("click", function(e){
			 if (inScreen) {
                    switch (e.button) {
                        case 0://left click
                            objParent = pick(objList, objParent, camera);
                            break;
                        case 1://center click
                            break;
                        case 2://right click
                            objParent = throwObj(objList, objParent, camera, scene);
                            break;
                        default:
                            break;
                    }
                }
		}, false);
		
		
    </script>
</body>
</html>
