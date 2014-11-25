#include <GL/gl.h>
#include <GL/glx.h>
#include <GL/glu.h>
#include <GL/glut.h>
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <time.h>

#define WIDTH 500
#define HEIGHT 500

/* global variables */
int Nvertice, Nface, Nanchor, Flag;
int *IsExist;
GLfloat *Vertices;
GLfloat *Anchors;
GLuint *Faces;
FILE *Fp;

/* load a CAD model from a .off file */
int load_off_file(int* pnv, GLfloat** pvertices, int* pnf, GLuint** pfaces, char* filename)
{
  FILE* fp;
  char buffer[256];
  int nv, nf, aux, i;
  GLfloat *vertices;
  GLuint *faces;

  /* open file */
  fp = fopen(filename, "r");
  if(fp == NULL)
  {
    printf("Can not open file %s\n", filename);
    *pnv = 0;
    *pvertices = NULL;
    *pnf = 0;
    *pfaces = NULL;
    return 1;
  }

  /* read file header */
  fgets(buffer, 256, fp);
  if(strncmp(buffer, "OFF", 3) != 0)
  {
    printf("Wrong format .off file %s\n", filename);
    return 1;
  }

  /* read numbers */
  fscanf(fp, "%d", &nv);
  fscanf(fp, "%d", &nf);
  fscanf(fp, "%d", &aux);

  /* allocate memory */
  vertices = (GLfloat*)malloc(sizeof(GLfloat)*nv*3);
  if(vertices == NULL)
  {
    printf("Out of memory!\n");
    return 1;
  }

  /* read vertices */
  for(i = 0; i < 3*nv; i++)
    fscanf(fp, "%f", vertices+i);

  /* allocate memory */
  if(nf != 0)
  {
    faces = (GLuint*)malloc(sizeof(GLuint)*nf*3);
    if(faces == NULL)
    {
      printf("Out of memory\n");
      return 1;
    }

    /* read faces */
    for(i = 0; i < nf; i++)
    {
      fscanf(fp, "%d", &aux);
      if(aux != 3)
      {
        printf("Face contains more than 3 vertices!\n");
        return 1;
      }
      fscanf(fp, "%d", faces + 3*i);
      fscanf(fp, "%d", faces + 3*i+1);
      fscanf(fp, "%d", faces + 3*i+2);
    }
  }
  else
    faces = NULL;

  fclose(fp);
  *pnv = nv;
  *pvertices = vertices;
  *pnf = nf;
  *pfaces = faces;
  return 0;
}

/* load anchor points from file */
void load_anchor_points(char **argv)
{
  int i, j, nv, nf;
  char filename[256];

  char *names_aeroplane[] = {"left_elevator", "left_wing", "noselanding", "right_elevator",
            "right_wing", "rudder_lower", "rudder_upper", "tail"};
  char *names_bed[] = {"back_left", "back_right",
            "frame_upper_left", "frame_upper_right",
            "frame_lower_left", "frame_lower_right",
            "mattres_upper_left", "mattres_upper_right",
            "mattres_lower_left", "mattres_lower_right"};
  char *names_boat[] = {"head", "head_down", "head_left", "head_right",
	    "tail_left", "tail_right", "tail"};
  char *names_bicycle[] = {"head_center", "left_back_wheel", "left_front_wheel",
            "left_handle", "left_pedal_center", "right_back_wheel",
            "right_front_wheel", "right_handle", "right_pedal_center",
            "seat_back", "seat_front"};
  char *names_bottle[] = {"mouth", "body", "body_left", "body_right", 
	    "bottom", "bottom_left", "bottom_right"};
  char *names_bus[] = {"body_back_left_lower", "body_back_left_upper",
            "body_back_right_lower", "body_back_right_upper",
            "body_front_left_upper", "body_front_right_upper",
            "body_front_left_lower", "body_front_right_lower",
            "left_back_wheel", "left_front_wheel",
            "right_back_wheel", "right_front_wheel"};        
  char *names_car[] = {"left_front_wheel", "left_back_wheel",
            "right_front_wheel", "right_back_wheel",
            "upper_left_windshield", "upper_right_windshield",
            "upper_left_rearwindow", "upper_right_rearwindow",
            "left_front_light", "right_front_light",
            "left_back_trunk", "right_back_trunk"};
  char *names_cellphone[] = {"insidescreen_lower_left", "insidescreen_lower_right",
            "insidescreen_upper_left", "insidescreen_upper_right",
            "lowerkeyboard_lower_left", "lowerkeyboard_lower_right",
            "lowerkeyboard_upper_left", "lowerkeyboard_upper_right",
            "outsidescreen_lower_left", "outsidescreen_lower_right",
            "outsidescreen_upper_left", "outsidescreen_upper_right",
            "upperkeyboard_lower_left", "upperkeyboard_lower_right",
            "upperkeyboard_upper_left", "upperkeyboard_upper_right"};
  char *names_chair[] = {"back_upper_left", "back_upper_right",
            "seat_upper_left", "seat_upper_right",
            "seat_lower_left", "seat_lower_right",
            "leg_upper_left", "leg_upper_right",
            "leg_lower_left", "leg_lower_right"};
  char *names_iron[] = {"handle_back", "handle_top", "back_left", "back_right", "tip"};
  char *names_motorbike[] = {"back_seat", "front_seat", "head_center", "headlight_center",
            "left_back_wheel", "left_front_wheel","left_handle_center",
            "right_back_wheel", "right_front_wheel", "right_handle_center"};
  char *names_mouse[] = {"peak", "head", "scroll_lower", "scroll_upper", "tail"};
  char *names_mug[] = {"bottom_near_handle", "bottom_opposite_handle",
            "handle_bottom", "handle_top", "top_near_handle", "top_opposite_handle"};
  char *names_shoe[] = {"back_bottom", "back_top", "front_bottom", "front_line", "front_top"};
  char *names_sofa[] = {"front_bottom_left", "front_bottom_right",
            "seat_bottom_left", "seat_bottom_right", "left_bottom_back",
            "right_bottom_back", "top_left_corner",  "top_right_corner",
            "seat_top_left", "seat_top_right"};
  char *names_stapler[] = {"back_lower_left", "back_lower_right", "back_upper_left",
            "back_upper_right", "front_upper_left",
            "front_upper_right", "front_bottom_left", "front_bottom_right"};
  char *names_diningtable[] = {"leg_upper_left", "leg_upper_right", "leg_lower_left", "leg_lower_right",
            "top_upper_left", "top_upper_right", "top_lower_left", "top_lower_right",
            "top_up", "top_down", "top_left", "top_right"};
  char *names_toaster[] = {"leftside_bottom_left", "leftside_bottom_right",
            "leftside_top_left", "leftside_top_right",
            "rightside_bottom_left", "rightside_bottom_right",
            "rightside_top_left", "rightside_top_right"};
  char *names_train[] = {"head_left_bottom", "head_left_top", "head_right_bottom", "head_right_top", "head_top",
            "mid1_left_bottom", "mid1_left_top", "mid1_right_bottom", "mid1_right_top",
            "mid2_left_bottom", "mid2_left_top", "mid2_right_bottom", "mid2_right_top",
            "tail_left_bottom", "tail_left_top", "tail_right_bottom", "tail_right_top"};
  char *names_tvmonitor[] = {"front_bottom_left", "front_bottom_right",
            "front_top_left", "front_top_right",
            "back_bottom_left", "back_bottom_right",
            "back_top_left", "back_top_right"};

  char **names;

  GLfloat *vertices;
  GLuint *faces;

  if(strcmp(argv[1], "aeroplane") == 0)
  {
    Nanchor = 8;
    names = names_aeroplane;
  }
  else if(strcmp(argv[1], "bed") == 0)
  {
    Nanchor = 10;
    names = names_bed;
  }
  else if(strcmp(argv[1], "boat") == 0)
  {
    Nanchor = 7;
    names = names_boat;
  }
  else if(strcmp(argv[1], "bicycle") == 0)
  {
    Nanchor = 11;
    names = names_bicycle;
  }
  else if(strcmp(argv[1], "bottle") == 0)
  {
    Nanchor = 7;
    names = names_bottle;
  }
  else if(strcmp(argv[1], "bus") == 0)
  {
    Nanchor = 12;
    names = names_bus;
  }
  else if(strcmp(argv[1], "car") == 0)
  {
    Nanchor = 12;
    names = names_car;
  }
  else if(strcmp(argv[1], "cellphone") == 0)
  {
    Nanchor = 16;
    names = names_cellphone;
  }
  else if(strcmp(argv[1], "chair") == 0)
  {
    Nanchor = 10;
    names = names_chair;
  }
  else if(strcmp(argv[1], "iron") == 0)
  {
    Nanchor = 5;
    names = names_iron;
  }
  else if(strcmp(argv[1], "motorbike") == 0)
  {
    Nanchor = 10;
    names = names_motorbike;
  }
  else if(strcmp(argv[1], "mouse") == 0)
  {
    Nanchor = 5;
    names = names_mouse;
  }
  else if(strcmp(argv[1], "mug") == 0)
  {
    Nanchor = 6;
    names = names_mug;
  }
  else if(strcmp(argv[1], "shoe") == 0)
  {
    Nanchor = 5;
    names = names_shoe;
  }
  else if(strcmp(argv[1], "sofa") == 0)
  {
    Nanchor = 10;
    names = names_sofa;
  }
  else if(strcmp(argv[1], "stapler") == 0)
  {
    Nanchor = 8;
    names = names_stapler;
  }
  else if(strcmp(argv[1], "diningtable") == 0)
  {
    Nanchor = 12;
    names = names_diningtable;
  }
  else if(strcmp(argv[1], "toaster") == 0)
  {
    Nanchor = 8;
    names = names_toaster;
  }
  else if(strcmp(argv[1], "train") == 0)
  {
    Nanchor = 17;
    names = names_train;
  }
  else if(strcmp(argv[1], "tvmonitor") == 0)
  {
    Nanchor = 8;
    names = names_tvmonitor;
  }
  else
  {
    printf("The anchor points of %s are not defined!\n", argv[1]);
    exit(1);
  }

  Anchors = (GLfloat*)malloc(sizeof(GLfloat)*Nanchor*3);
  if(Anchors == NULL)
  {
    printf("Out of memory!\n");
    exit(1);
  }
  memset(Anchors, 0, sizeof(GLfloat)*Nanchor*3);

  /* flag for anchor points */
  IsExist = (int*)malloc(sizeof(int)*Nanchor);
  if(IsExist == NULL)
  {
    printf("Out of memory!\n");
    exit(1);
  }

  for(i = 0; i < Nanchor; i++)
  {
    sprintf(filename, "%s_%s.off", argv[2], names[i]);
    load_off_file(&nv, &vertices, &nf, &faces, filename);
    if(nv == 0)
    {
      printf("%s dose not exist\n", names[i]);
      IsExist[i] = 0;
    }
    else
    {
      IsExist[i] = 1;
      for(j = 0; j < nv; j++)
      {
        Anchors[3*i] += vertices[3*j];
        Anchors[3*i+1] += vertices[3*j+1];
        Anchors[3*i+2] += vertices[3*j+2];
      }
      Anchors[3*i] /= nv;
      Anchors[3*i+1] /= nv;
      Anchors[3*i+2] /= nv;
      printf("%s: %.4f, %.4f, %.4f\n", names[i], Anchors[3*i], Anchors[3*i+1], Anchors[3*i+2]);
      free(vertices);
      if(faces != NULL)
        free(faces);
    }
  }
}

/* drawing function */
void display(void)
{
  int i, aind, eind;
  int *visibility;
  GLint viewport[4];
  GLdouble mvmatrix[16], projmatrix[16];
  GLdouble x, y, z;
  GLdouble a = 0, e = 0, d = 3;
  GLfloat depth;

  glEnable(GL_DEPTH_TEST);

  /* vertice array */
  glEnableClientState(GL_VERTEX_ARRAY);
  glVertexPointer(3, GL_FLOAT, 0, Vertices);


  if(Flag == 1)
    fprintf(Fp, "%d\n", 72*73);

  for(aind = 0; aind < 72; aind++)
  {
    a = aind * 5.0;
    for(eind = 0; eind < 73; eind++)
    {
      e = -90 + eind * 2.5;

      glClearColor(1.0, 1.0, 1.0, 0.0);
      glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

      glMatrixMode(GL_PROJECTION);
      glLoadIdentity();
      gluPerspective(30.0, 1.0, d-0.5, d+0.5);
      glViewport(0, 0, WIDTH, HEIGHT);

      glMatrixMode(GL_MODELVIEW);
      glLoadIdentity();
      glTranslatef(0.0, 0.0, -d);
      glRotatef(e-90.0, 1.0, 0.0, 0.0);
      glRotatef(-a, 0.0, 0.0, 1.0);

      /* draw lines */
      glPolygonMode(GL_FRONT_AND_BACK, GL_LINE);
      glColor3f(0.0, 0.0, 1.0);
      glDrawElements(GL_TRIANGLES, 3*Nface, GL_UNSIGNED_INT, Faces);

      /* hidden line removal */
      glPolygonMode(GL_FRONT_AND_BACK, GL_FILL);
      glEnable(GL_POLYGON_OFFSET_FILL);
      glPolygonOffset(1.0, 1.0);
      glColor3f(1.0, 1.0, 1.0);
      glDrawElements(GL_TRIANGLES, 3*Nface, GL_UNSIGNED_INT, Faces);
      glDisable(GL_POLYGON_OFFSET_FILL);

      /* get the matrices */
      glGetIntegerv(GL_VIEWPORT, viewport);
      glGetDoublev(GL_MODELVIEW_MATRIX, mvmatrix);
      glGetDoublev(GL_PROJECTION_MATRIX, projmatrix);

      /* for each anchor point */
      glColor3f(1.0, 0.0, 0.0);
      glPointSize(10.0);
      visibility = (int*)malloc(sizeof(int)*Nanchor);
      if(visibility == NULL)
      {
        printf("out of memory\n");
        exit(1);
      }
      for(i = 0; i < Nanchor; i++)
      {
        if(IsExist[i] == 0)
        {
          visibility[i] = 0;
          continue;
        }
        gluProject(Anchors[3*i], Anchors[3*i+1], Anchors[3*i+2], mvmatrix, projmatrix, viewport, &x, &y, &z);
        glReadPixels((GLint)x, (GLint)y, 1, 1, GL_DEPTH_COMPONENT, GL_FLOAT, &depth);

        if(z <= depth+0.05)
        {
          visibility[i] = 1;
          glBegin(GL_POINTS);
            glVertex3f(Anchors[3*i], Anchors[3*i+1], Anchors[3*i+2]);
          glEnd();
        }
        else
          visibility[i] = 0;
      }

      /* write to file */
      if(Flag == 1)
      {
        fprintf(Fp, "%f %f ", a, e);
        for(i = 0; i < Nanchor; i++)
          fprintf(Fp, "%d ", visibility[i]);
        fprintf(Fp, "\n");
      }

      free(visibility);
      glFlush();

    }
  }
  
  if(Flag == 0)
    Flag = 1;
  else
  {
    fclose(Fp);
    exit(0);
  }
}

void reshape(int w, int h)
{
  glViewport(0, 0, (GLsizei)w, (GLsizei)h);
}

int main(int argc, char** argv)
{
  char filename[256];

  glutInit(&argc, argv);
  glutInitDisplayMode(GLUT_SINGLE | GLUT_RGB | GLUT_DEPTH);
  glutInitWindowSize(WIDTH, HEIGHT);
  glutInitWindowPosition(100, 100);
  glutCreateWindow("anchor_depth_test");

  /* filename of the off file */
  sprintf(filename, "%s.off", argv[2]);
  /* load off file */
  load_off_file(&Nvertice, &Vertices, &Nface, &Faces, filename);
  printf("load off file done\n");
  /* load anchor points */
  load_anchor_points(argv);
  printf("load anchor points done\n");
  /* open file for output */
  sprintf(filename, "%s.vty", argv[2]);
  Fp = fopen(filename, "w");
  Flag = 0;

  glutDisplayFunc(display);
  glutReshapeFunc(reshape);
  glutMainLoop();
  return 0;
}
