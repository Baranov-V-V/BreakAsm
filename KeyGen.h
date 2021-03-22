#pragma once

//break
const int brk_pos = 16 * 2 + 1;
const char brk_chr = 235;

//fonts suff
const char* font = "Consolas";
const int font_size_y = 30;
const int font_size_x = 10;
const int thickness = 800;

//text coordinates
const int text_hat_x = 40;
const int text_hat_y = 200;

const int length_between =  300;

const int text_cat_x = 60;
const int text_cat_y = 40;

//text messages
const char* cat_message = "А тут можно посмотреть на котиков, наслаждайтесь :З";
const char* system_dev_msg = "start chrome https://github.com/baranov-V-V";
const char* messages_gen[] = {
    "Добро пожаловать во Взломщик bitcoin кошельков.",
    "Нажмите: Y (y) чтобы начать взлом",
};


//images
const int bitcoin_x = 200;
const int bitcoin_y = 40;

const int povezlo_x = 50;
const int povezlo_y = 330;

const int cat_image_x = 345;
const int cat_image_y = 150;

const int button_x_1 = 650;
const int button_y_1 = 430;

const int button_x_2 = 650;
const int button_y_2 = 630;

const int button_ret_x = 70;
const int button_ret_y = 150;

const int button_next_x = 70;
const int button_next_y = 290;

const int button_dev_x = 70;
const int button_dev_y = 430;

//mouse
const int button_size_x = 228;
const int button_size_y = 87;

int buttons = 0;
int screen_state = 1;

//progress bar
const int frame_x1 = 600;
const int frame_y1 = 350;

const int frame_x2 = 900;
const int frame_y2 = 375;

const int loading_x = 700;
const int loading_y = 310;

const int cat_loading_x = 730;
const int cat_loading_y = 0;

const int load_failed_x = 660;
const int load_failed_y = 260;

const int load_completed_x = 570;
const int load_completed_y = 230;

const char* loading_msg = "Loading...";

int current_cat = 0;

//pictures
const int cat_number = 9;
const int cat_name_len = 30;

RGBQUAD* buf_screen1 = nullptr;
RGBQUAD* buf_screen2 = nullptr;

HDC screen1 = nullptr;
HDC screen2 = nullptr;		

HDC bitcoin = nullptr;
HDC povezlo = nullptr;

HDC button1 = nullptr;
HDC button2 = nullptr;

HDC cat_loading = nullptr;
HDC loading_completed = nullptr;
HDC loading_failed = nullptr;

HDC button_ret = nullptr;
HDC button_next = nullptr;
HDC start_cat = nullptr;
HDC button_dev = nullptr;

HDC* cats;