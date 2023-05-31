#if UNITY_EDITOR
using UnityEngine;
using UnityEngine.SocialPlatforms;
using UnityEditor;
using System.Collections.Generic;
using System.Numerics;
/// <summary>
/// 美术刷草工具
/// </summary>
public class PaintDetailsEW : EditorWindow
{
    private GameObject AddObject;
    private static bool Enable;
    private Transform CurrentSelect;
    private int PlantSelect;
    private int brushSize;
    private float scaleRandom;
    private int density;

    private static GameObject[] Plants;
    private static Texture[] TexObjects;

    [MenuItem("AiferuFramework/库本身的功能/4.项目使用工具收集/8.美术射线刷草工具Bata", false, 4008)]
    static void Open()
    {
        Plants = new GameObject[6];
        TexObjects = new Texture[6];
        for (int i = 0; i < 6; i++)
        {
            Plants[i] = null;
        }
        var window = (PaintDetailsEW)EditorWindow.GetWindowWithRect(typeof(PaintDetailsEW), new Rect(0, 0, 386, 320), false, "Paint Detail");
        window.Show();
        Enable = true;
    }
    void OnInspectorUpdate()
    {
        Repaint();
    }

    void OnGUI()
    {
        CurrentSelect = Selection.activeTransform;

        GUILayout.Space(20);
        GUILayout.BeginHorizontal();
        GUILayout.FlexibleSpace();
        GUILayout.BeginVertical("box", GUILayout.Width(347));
        GUILayout.BeginHorizontal();
        GUILayout.Label("Add Assets", GUILayout.Width(125));

        AddObject = (GameObject)EditorGUILayout.ObjectField("", AddObject, typeof(GameObject), true, GUILayout.Width(160));
        if (GUILayout.Button("+", GUILayout.Width(40)))
        {
            for (int i = 0; i < 6; i++)
            {
                if (Plants[i] == null)
                {
                    Plants[i] = AddObject;
                   break;
                }
            }
        }

        GUILayout.EndHorizontal();
        GUILayout.EndVertical();
        GUILayout.FlexibleSpace();
        GUILayout.EndHorizontal();

        for (int i = 0; i < 6; i++)
        {
            if (Plants[i] != null)
                TexObjects[i] = AssetPreview.GetAssetPreview(Plants[i]) as Texture;
            else TexObjects[i] = null;
        }

        GUILayout.BeginHorizontal();
        GUILayout.FlexibleSpace();
        GUILayout.BeginVertical("box", GUILayout.Width(347));
        PlantSelect = GUILayout.SelectionGrid(PlantSelect, TexObjects, 6, "gridlist", GUILayout.Width(330), GUILayout.Height(55));

        GUILayout.BeginHorizontal();

        for (int i = 0; i < 6; i++)
        {
            if (GUILayout.Button("—", GUILayout.Width(52)))
            {
                //Plants[i] = null;
            }
        }

        GUILayout.EndHorizontal();

        GUILayout.EndVertical();
        GUILayout.FlexibleSpace();
        GUILayout.EndHorizontal();

        GUILayout.BeginHorizontal();
        GUILayout.FlexibleSpace();
        GUILayout.BeginVertical("box", GUILayout.Width(347));
        GUILayout.BeginHorizontal();
        GUILayout.Label("Setting", GUILayout.Width(145));
        GUILayout.EndHorizontal();
        brushSize = (int)EditorGUILayout.Slider("Brush Size", brushSize, 1, 36);
        scaleRandom = EditorGUILayout.Slider("Scale Random(+/-)", scaleRandom, 0.05f, 1f);
        density = (int)EditorGUILayout.Slider("Density", density, 1, 10);
        GUILayout.EndVertical();
        GUILayout.FlexibleSpace();
        GUILayout.EndHorizontal();

        GUILayout.BeginHorizontal();
        GUILayout.FlexibleSpace();
        GUILayout.BeginVertical(GUILayout.Width(347));

       
    }
}
#endif