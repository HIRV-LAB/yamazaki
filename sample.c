#include <stdio.h>

void main(void)
{
	int array1[100];
	int array2[100];
	int vertex2[100][100];
	int vertex3[100][100];
	int switch_vertex3[100][100][100]
	int roop,j,tmp1,tmp2,tmp3,tmp4,tmp5; //コメント

	/*コメント*/


	/*   コメント
		 コメント
	*/


	for(roop = 0; roop < 100; roop++){ /*コメント*/
		if(array[roop] < 500){
			for(j = 0; j < 60; j++){
				if(array[j] < 100){
					printf("%d\n", array[j]);
				}
				else{
					printf("%d\n", array[roop]);
				}
			}
		}
		else if(array[roop] < 100){
			
		}
		else{
			
		}
	}
	for(tmp1 = 0 ; tmp1 < 40 ; tmp1++){
		for(tmp2 = 0; tmp2< 60; tmp2++){
			if(vertex2[tmp1][tmp2] < 3){
    			printf("2次元配列のテスト\n");
    		}
  		}
  	}

  	for(tmp3 = 0; tmp3 < 60; tmp3++){
  		for(tmp4 = 0; tmp4 < 60; tmp4++){
  			for(tmp5 = 0; tmp5 < 60; tmp5++){
  				if(vertex3[tmp3][tmp4][tmp5] < 40){
    				printf("3次元配列のテスト\n");
    			}
    			switch(switch_vertex3[tmp3][tmp4][tmp5]){
    				case 1 : printf("switch文のサンプル1\n");
    				case 2 : printf("switch文のサンプル2\n");
    				case 3 : printf("switch文のサンプル3\n");
    			}
  			}		
  		}
  	}
}
