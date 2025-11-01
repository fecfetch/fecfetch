 
import math
import random
import pygame
import tkinter as tk
from tkinter import messagebox
import random

from pygame.locals import *

def name():
    global a
    pygame.init()
    screen = pygame.display.set_mode((480, 360))
    a = ""
    font = pygame.font.Font(None, 50)
  
    while True:
        for evt in pygame.event.get():
            if evt.type == KEYDOWN:
                if evt.key == K_BACKSPACE:
                    a = a[:-1]
                elif evt.key == K_RETURN:
                    return 
                else:
                    a += evt.unicode
            elif evt.type == QUIT:
                return
        screen.fill((0, 0, 0))
        block = font.render('hizi girin(1-150): ' + a, True, (255, 255, 255))
        rect = block.get_rect()
        rect.center = screen.get_rect().center
        screen.blit(block, rect)
        pygame.display.flip()




class cube(object):
    rows=20
    g=500
    def __init__(self,start,xyonu=1,yyonu=0,color=(255,0,0)):
        self.pos=start
        self.xyonu=1
        self.yyonu=0
        self.color=color
    def move(self,xyonu,yyonu):
        self.xyonu=xyonu
        self.yyonu=yyonu
        self.pos =(self.pos[0]+self.xyonu,self.pos[1]+self.yyonu)
    def ciz(self,surface,goz=False):
        dis=self.g//self.rows
        i=self.pos[0]
        j=self.pos[1]
        pygame.draw.rect(surface,self.color,(i*dis+1,j*dis+1,dis-2,dis-2))
        if goz:
            merkez= dis//2
            yaricap=3
            orta1=(i*dis+merkez-yaricap,j*dis+8)
            orta2=(i*dis+dis-yaricap*2,j*dis+8)
            pygame.draw.circle(surface,(0,0,0),orta1,yaricap)
            pygame.draw.circle(surface,(0,0,0),orta2,yaricap)
  
class snake(object):
    
    body=[]
    turns={}
    def __init__(self,color,pos):
        self.color=color
        self.kafa=cube(pos)
        self.body.append(self.kafa)
        self.xyonu=0
        self.yyonu=1
    def move(self):
        
        for event in pygame.event.get():
            if event.type==pygame.QUIT:
                pygame.quit()
            keys=pygame.key.get_pressed()
            for key in keys:
                if keys[pygame.K_LEFT]:
                    self.xyonu=-1
                    self.yyonu=0
                    self.turns[self.kafa.pos[:]]=[self.xyonu,self.yyonu]
                elif keys[pygame.K_RIGHT]:
                    self.xyonu=1
                    self.yyonu=0
                    self.turns[self.kafa.pos[:]]=[self.xyonu,self.yyonu]
                elif keys[pygame.K_UP]:
                    self.xyonu=0
                    self.yyonu=-1
                    self.turns[self.kafa.pos[:]]=[self.xyonu,self.yyonu]
                elif keys[pygame.K_DOWN]:
                    self.xyonu=0
                    self.yyonu=1
                    self.turns[self.kafa.pos[:]]=[self.xyonu,self.yyonu]
        for i,c in enumerate(self.body):
            p=c.pos[:]
            if p in self.turns:
                turn=self.turns[p]
                c.move(turn[0],turn[1])
                if i == len(self.body)-1:
                    self.turns.pop(p)
            else:
                if c.xyonu==-1 and c.pos[0]<=0: c.pos=(c.rows-1,c.pos[1])
                elif c.xyonu==1 and c.pos[0] >=c.rows-1 : c.pos=(0,c.pos[1])
                elif c.yyonu==1 and c.pos[1] >= c.rows-1 : c.pos=(c.pos[0],0)
                elif c.yyonu==-1 and c.pos[1] <=0 : c.pos=(c.pos[0],c.rows-1)
                else:c.move(c.xyonu,c.yyonu)
    def reset(self,pos):
        self.head=cube(pos)
        self.body=[]
        self.body.append(self.head)
        self.turns={}
        self.xyonu=0
        self.yyonu=1
    def kupEkle(self):
        tail=self.body[-1]
        dx,dy=tail.xyonu,tail.yyonu

        if dx == 1 and dy == 0:
            self.body.append(cube((tail.pos[0]-1,tail.pos[1])))
        elif dx == -1 and dy == 0:
            self.body.append(cube((tail.pos[0]+1,tail.pos[1])))
        elif dx == 0 and dy == 1:
            self.body.append(cube((tail.pos[0],tail.pos[1]-1)))
        elif dx == 0 and dy == -1:
            self.body.append(cube((tail.pos[0],tail.pos[1]+1)))
 
        self.body[-1].xyonu = dx
        self.body[-1].yyonu = dy
        
    def ciz(self,surface):
        for i,c in enumerate(self.body):
            if i==0:
                c.ciz(surface,True)
            else:
                c.ciz(surface)

def gridciz(g,rows,surface):
    bosluk=g//rows
    x=0
    y=0
    for l in range(rows):
        x=x+bosluk
        y=y+bosluk
        pygame.draw.line(surface,(255,255,254),(x,0),(x,g))
        pygame.draw.line(surface,(255,255,254),(0,y),(g,y))
        
 
def winciz(surface):
    global s,snack,gen,rows
    surface.fill((0,0,0))
    s.ciz(surface)
    snack.ciz(surface)
    gridciz(gen, rows, surface)
    pygame.display.update()
def randomSnack(rows,item):
    global renk,b,a,d
    konlar=item.body
    renk=random.randint(1,5)
    if renk==1:
        b=(0,255,255)
        a=1
    elif renk==2:
        b=(0,0,255)
        a=2
    elif renk==3:
        b=(0,255,0)
        a=3
    elif renk ==4:
        b=(255,0,255)
        a=4
    elif renk ==5:
        b=(255,255,255)
        a=5
    while True:
        x=random.randrange(rows)
        y=random.randrange(rows)
        if len(list(filter(lambda z:z.pos==(x,y),konlar)))>0:
            continue
        else:
            break
    return (x,y)
def messageBox(subject,content):
    root=tk.Tk()
    root.attributes('-topmost',True)
    root.withdraw()
    messagebox.showinfo(subject,content)
    try:
        root.destroy()
    except:
        pass

def main():
    global s,snack,gen,rows,a,renk,b
    if __name__ == "__main__":
        name()
    s=snake((255,0,0), (10,10))
    gen=500
    rows=20
    snack=cube(randomSnack(rows,s),color=b)
    win=pygame.display.set_mode((gen,gen))
    bayrak=True
    clock=pygame.time.Clock()
    
    while bayrak:
        hiz=int(a)
        pygame.time.delay(hiz)
        clock.tick(20)
        s.move()
        if s.body[0].pos==snack.pos:
            s.kupEkle()
            snack=cube(randomSnack(rows,s),color=b)
        for x in range(len(s.body)):
            if s.body[x].pos in list(map(lambda z:z.pos,s.body[x+1:])):
                print('Score : ',len(s.body))
                messageBox('You a loser!','Try again you loser!!')
                messageBox()
                s.reset((10,10))
                break
        winciz(win)
    pass
main()
