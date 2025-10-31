import numpy as np
import pygame
import sys
import math

mavi=(0,0,255)
BLACK=(0,0,0)
RED = (255,0,0)
YELLOW = (255,255,0)
pygame.init()
row_sayi=6
col=7
def basla():
    tahta=np.zeros((6,7))
    return tahta
def gecerli(board,secim):
    return tahta[5][secim]==0
def bos_sira(tahta,secim):
    for i in range(row_sayi):
        if tahta[i][secim]==0:
            return i
def koy(tahta,row,secim,piece):
    tahta[row][secim]=piece
def goster(tahta):
    print(np.flip(tahta, 0))
    print(range(3,row_sayi-3))
def kazan(tahta,piece):
    for c in range(col-3):
        for r in range(row_sayi):
            if tahta[r][c]==piece and tahta[r][c+1]==piece and tahta[r][c+2]==piece and tahta[r][c+3]==piece:
                return True
    for c in range(col): 
        for r in range(row_sayi-3):
            if tahta[r][c]==piece and tahta[r+1][c]==piece and tahta[r+2][c]==piece and tahta[r+3][c]==piece:
                return True
    for c in range(col-3):
        for r in range(row_sayi-3):
            if tahta[r][c]==piece and tahta[r+1][c+1]==piece and tahta[r+2][c+2]==piece and tahta[r+3][c+3]==piece:
                return True
    for c in range(col-3):
        for r in range(3,row_sayi-3):
            if tahta[r][c]==piece and tahta[r-1][c+1]==piece and tahta[r-2][c+2]==piece and tahta[r-3][c+3]==piece:
                return True
def tahtaciz(tahta):
    for c in range(col):
        for r in range(row_sayi):
            pygame.draw.rect(screen,mavi,(c*SQUARESIZE, r*SQUARESIZE+SQUARESIZE, SQUARESIZE, SQUARESIZE))
            pygame.draw.circle(screen, BLACK,(int(c*SQUARESIZE+SQUARESIZE/2), int(r*SQUARESIZE+SQUARESIZE+SQUARESIZE/2)), RADIUS)
    for c in range(col):
        for r in range(row_sayi):
            if tahta[r][c] == 1:
                pygame.draw.circle(screen, RED, (int(c*SQUARESIZE+SQUARESIZE/2), yuk-int(r*SQUARESIZE+SQUARESIZE/2)), RADIUS)
            elif tahta[r][c] ==2:
                pygame.draw.circle(screen, YELLOW, (int(c*SQUARESIZE+SQUARESIZE/2), yuk-int(r*SQUARESIZE+SQUARESIZE/2)), RADIUS)
    pygame.display.update()


tahta = basla()         
                            
bitti=False

sira=0

SQUARESIZE=100
RADIUS=int(SQUARESIZE/2 - 5)   
yuk=(row_sayi+1)*SQUARESIZE
gen=col*SQUARESIZE
boyut=(gen,yuk)
screen=pygame.display.set_mode(boyut)
tahtaciz(tahta)
pygame.display.update()
font=pygame.font.SysFont('Monospace',70)
while not bitti:
    for event in pygame.event.get():
        if event.type==pygame.QUIT:
            sys.exit()
        if event.type==pygame.MOUSEMOTION:
            pygame.draw.rect(screen,BLACK,(0,0,yuk,SQUARESIZE))
            posx=event.pos[0]
            if sira==0:
                pygame.draw.circle(screen, RED, (posx, int(SQUARESIZE/2)), RADIUS)
            else:
                pygame.draw.circle(screen, YELLOW, (posx, int(SQUARESIZE/2)), RADIUS)
            pygame.display.update()
        if event.type==pygame.MOUSEBUTTONDOWN:
            
            if sira==0:
                posx=event.pos[0]
                secim= int(math.floor(posx/SQUARESIZE))
                if gecerli(tahta,secim):
                    row=bos_sira(tahta,secim)
                    koy(tahta,row,secim,1)
                if kazan(tahta,1):
                    pygame.draw.rect(screen,BLACK,(0,0,yuk,SQUARESIZE))
                    label=font.render('1. kisi kazandi',1,RED)
                    screen.blit(label,(40,10))
                    bitti=True
                    
            else:
                posx=event.pos[0]
                secim= int(math.floor(posx/SQUARESIZE))
                if gecerli(tahta,secim):
                    row=bos_sira(tahta,secim)
                    koy(tahta,row,secim,2)
                if kazan(tahta,2):
                    pygame.draw.rect(screen,BLACK,(0,0,yuk,SQUARESIZE))
                    label=font.render('2. kisi kazandi',1,YELLOW)
                    screen.blit(label,(40,10))
                    bitti=True
        
            goster(tahta)
            tahtaciz(tahta)
            sira+=1
            sira= sira%2
            if bitti:
                pygame.time.wait(3000)
        
