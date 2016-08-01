package 
{
import flash.display.Sprite;

import taven.LimitEnterModule;
import taven.MenuBarModule;
import taven.ParkingModule;
import taven.PersonInfoModule;
import taven.PlayInfoModule;
import taven.RankGiftModule;
import taven.RankViewModule;
import taven.RankVipModule;
import taven.SpeakerModule;
import taven.UserInfo;
import taven.leftMap;
import taven.rightView.MenuList;
import taven.sidesGroup;

public class TavenModule extends Sprite
	{
	
		private var left:leftMap;
		private var parkModle:ParkingModule;
		private var personModule:PersonInfoModule;
		private var palyInfoModule:PlayInfoModule;
		private var rankGiftModule:RankGiftModule;
		private var rankViewModule:RankViewModule;
		private var sideGroup:sidesGroup;
		private var usrInfoView:UserInfo;
		private var speakerModule:SpeakerModule;
		private var menuBarModule:MenuBarModule;
		private var menuList:MenuList;
		private var rankVipModule:RankVipModule;
		private var limitEnterModule:LimitEnterModule;

		public function TavenModule()
		{
		//	usrInfoView  = new UserInfo();
		/*	var data:Object = new Object();
			data.name = "111";
			data.cmdId =12;
			data.value = 3333;
			trace(JSON.stringify(data));*/
		}

		private function testRankView():void
		{


		}
		
		
		private function testRankGiftView():void
		{


		}
		
	}
}