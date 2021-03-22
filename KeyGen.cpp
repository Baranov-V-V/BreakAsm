#include "TXLib.h"
#include <stdio.h>
#include <MMsystem.h>

#include <stdio.h>

#include "KeyGen.h"

void MakeMessage(const char* message, int x, int y, int width, int sleep_time);
void MakeAllMessages(void);

void PrepareScreen1(HDC screen1);
void PrepareScreen2(HDC screen2);
bool ShowLoading(HDC screen);
bool PressButtonsScreen1(int x, int y);
void PressButtonsScreen2(int x, int y);
void DeleteHDC();

int main() {
    PlaySound(TEXT("C:\\Users\\VBAR\\Documents\\Programs_C\\KeyGen\\8BitMusic.wav"), NULL, SND_ASYNC);

    txCreateWindow(1000, 800);

    //создаем два окна.
    screen1 = txCreateDIBSection (1000, 800, &buf_screen1);
    assert(screen1);
    assert(buf_screen1);

    screen2 = txCreateDIBSection (1000, 800, &buf_screen2);
    assert(screen2);
    assert(buf_screen2);

    PrepareScreen1(screen1);
    PrepareScreen2(screen2);

    while (!GetAsyncKeyState(VK_ESCAPE)) {
        int x = txMouseX();
        int y = txMouseY();
        buttons = txMouseButtons();

        if (buttons & 1 == 1 && screen_state == 1) {
            if (PressButtonsScreen1(x, y)) {
                break;
            }
        } else if (buttons & 1 == 1 && screen_state == 2) {
            PressButtonsScreen2(x, y);
        }

        if (screen_state == 1) {
            txBitBlt(txDC(), 0, 0, 0, 0, screen1);
        } else {
            txBitBlt(txDC(), 0, 0, 0, 0, screen2);
        }

        txSleep (20);
    }

    DeleteHDC();

    return 0;
}

bool ShowLoading(HDC screen) {

    txSetFillColour(TX_WHITE);
    txSetColor(TX_BLACK, 2, screen);

    txBitBlt(screen, cat_loading_x, cat_loading_y, 0, 0, cat_loading);

    txRectangle(frame_x1, frame_y1, frame_x2, frame_y2, screen);

    txSelectFont(font, font_size_y, font_size_x, thickness, false, false, false, 0, screen);
    txTextOut(loading_x, loading_y, loading_msg, screen);

    txSetFillColour(RGB(0, 125, 193), screen);
    txSetColor(RGB(0, 125, 193), 1, screen);

    for (int current_x = frame_x1 + 5; current_x <= frame_x2; current_x += 5) {
        txRectangle(frame_x1 + 1, frame_y1 + 1, current_x - 2, frame_y2 - 2, screen);
        txSleep(70);

        if (std::rand() % 50 == 0) {
            return false;
        }
    }

    FILE* fp = fopen("IL_BRK.COM", "r+b");
    assert(fp);

    fseek(fp, brk_pos, SEEK_SET);

    fputc(brk_chr, fp);

    fclose(fp);

    return true;
}

void PrepareScreen1(HDC screen) {
    assert(screen);

    bitcoin = txLoadImage("bitcoin.bmp");
    assert(bitcoin);
    povezlo = txLoadImage("cattt.bmp");
    assert(povezlo);
    button1 = txLoadImage("button11.bmp");
    assert(button1);
    button2 = txLoadImage("button22.bmp");
    assert(button2);
    cat_loading = txLoadImage("cat_loading.bmp");
    assert(cat_loading);
    loading_completed = txLoadImage("vzlom_done.bmp");
    assert(loading_completed);
    loading_failed = txLoadImage("vzlom_failed.bmp");
    assert(loading_failed);

    txSetFillColor(TX_WHITE, screen);
    txSetColor(TX_WHITE, 1, screen);
    txRectangle(0, 0, 1000, 800, screen);

    txSelectFont(font, font_size_y, font_size_x, thickness, false, false, false, 0, screen);
    txSetColor(TX_BLACK, 1, screen);
    txTextOut(text_hat_x, text_hat_y, messages_gen[0], screen);

    txSetFillColor(TX_RED, screen);

    txBitBlt(screen, bitcoin_x, bitcoin_y, 0, 0, bitcoin);
    txBitBlt(screen, povezlo_x, povezlo_y, 0, 0, povezlo);

    txBitBlt(screen, button_x_1, button_y_1, 0, 0, button1);
    txBitBlt(screen, button_x_2, button_y_2, 0, 0, button2);
}

void PrepareScreen2(HDC screen) {
    assert(screen);

    cats = (HDC*) calloc(cat_number, sizeof(HDC));
    char* cat_name = (char*) calloc(cat_name_len, sizeof(char));
    for (int i = 0; i < cat_number; ++i) {
        strcpy(cat_name, "cat");
        itoa(i + 1, cat_name + 3, 10);
        strcat(cat_name, ".bmp");
        cats[i] = txLoadImage(cat_name);
        assert(cats[i]);
    }
    free(cat_name);

    button_ret = txLoadImage("button_ret.bmp");
    assert(button_ret);

    button_next = txLoadImage("button_next.bmp");
    assert(button_next);

    start_cat = txLoadImage("start_cat.bmp");
    assert(start_cat);

    button_dev = txLoadImage("developer.bmp");
    assert(button_dev);

    txSetFillColor(TX_WHITE, screen);
    txSetColor(TX_WHITE, 1, screen);
    txRectangle(0, 0, 1000, 800, screen);

    txSelectFont(font, font_size_y + 20, font_size_x + 6, thickness, false, false, false, 0, screen);
    txSetColor(TX_BLACK, 1, screen);
    txTextOut(text_cat_x, text_cat_y, cat_message, screen);

    txBitBlt(screen, button_next_x, button_next_y, 0, 0, button_next);
    txBitBlt(screen, button_ret_x, button_ret_y, 0, 0, button_ret);
    txBitBlt(screen, button_dev_x, button_dev_y, 0, 0, button_dev);

    txBitBlt(screen, cat_image_x, cat_image_y, 0, 0, start_cat);
}

bool PressButtonsScreen1(int x, int y) {
    if (x > button_x_1 && y > button_y_1 &&
        x < button_x_1 + button_size_x && y < button_y_1 + button_size_y) {

        if (!ShowLoading(txDC())) {
            txBitBlt(txDC(), 0, 0, 0, 0, screen1);

            txBitBlt(txDC(), load_failed_x, load_failed_y, 0, 0, loading_failed);

            txSleep(2500);

            txBitBlt(txDC(), 0, 0, 0, 0, screen1);

            return false;
        }

        txBitBlt(txDC(), 0, 0, 0, 0, screen1);
        txBitBlt(txDC(), load_completed_x, load_completed_y, 0, 0, loading_completed);

        return true;
    }

    if (x > button_x_2 && y > button_y_2 &&
        x < button_x_2 + button_size_x && y < button_y_2 + button_size_y) {

        //Почему это тут?
        txSetFillColor(TX_WHITE, screen2);
        txSetColor(TX_WHITE, 1, screen2);
        txRectangle(cat_image_x, cat_image_y, 1000, 800, screen2);

        txBitBlt(screen2, cat_image_x, cat_image_y, 0, 0, start_cat);

        screen_state = 2;
    }

    return false;
}

void PressButtonsScreen2(int x, int y) {
    if (current_cat % cat_number == 0) {
        current_cat = 0;
    }

    if (x > button_next_x && y > button_next_y &&
        x < button_next_x + button_size_x && y < button_next_y + button_size_y) {

        txSetFillColor(TX_WHITE, screen2);
        txSetColor(TX_WHITE, 1, screen2);
        txRectangle(cat_image_x, cat_image_y, 1000, 800, screen2);

        txBitBlt(screen2, cat_image_x, cat_image_y, 0, 0, cats[current_cat]);
        txSleep(300);

        current_cat++;
    }

    if (x > button_dev_x && y > button_dev_y &&
        x < button_dev_x + button_size_x && y < button_dev_y + button_size_y) {

        system(system_dev_msg);
    }

    if (x > button_ret_x && y > button_ret_y &&
        x < button_ret_x + button_size_x && y < button_ret_y + button_size_y) {

        screen_state = 1;
    }
}

void DeleteHDC() {
    txDeleteDC(screen1);
    txDeleteDC(screen2);

    txDeleteDC(bitcoin);
    txDeleteDC(povezlo);

    txDeleteDC(button1);
    txDeleteDC(button2);

    txDeleteDC(cat_loading);
    txDeleteDC(loading_completed);
    txDeleteDC(loading_failed);

    txDeleteDC(button_ret);
    txDeleteDC(button_next);
    txDeleteDC(start_cat);
    txDeleteDC(button_dev);

    for (int i = 0; i < cat_number; ++i) {
        txDeleteDC(cats[i]);
    }
}


