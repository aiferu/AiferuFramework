#if UNITY_EDITOR
using System;
using System.Collections;
using System.Collections.Generic;
using UnityEditor;
using UnityEngine;
namespace AiferuFramework.ArtBrushTool
{
    [InitializeOnLoad]
    public class PaintDetailsEXtends
    {
        private static int layerMask =0;
        #region �󶨳���GUI��Ⱦ�ص�
        static PaintDetailsEXtends()
        {
            //�󶨳���GUI��Ⱦ�ص�
            SceneView.duringSceneGui += OnSceneGUI;
        }

        ~PaintDetailsEXtends()
        {
            SceneView.duringSceneGui -= OnSceneGUI;
        }
        #endregion

        //Scene���ص�����
        static void OnSceneGUI(SceneView view)
        {
            //�ж��Ƿ���������ˢ�ݹ���
            if (ArtBrushToolEW.Enable)
            {
                Debug.Log("�һ����һ���");
                Planting();
            }
        }


        static void Planting()
        {
            //ʹ������ȡ���潻��
            Event e = Event.current;
            //�����������ʱ
            RaycastHit raycastHit = new RaycastHit();
            Ray terrainRay = HandleUtility.GUIPointToWorldRay(e.mousePosition);
            Debug.DrawLine(terrainRay.origin, terrainRay.GetPoint(100), Color.red);
            //���Ʊ�ˢ
            
            if (Physics.Raycast(terrainRay, out raycastHit, Mathf.Infinity))
            {
                //���Ʊ�ˢ
                    
                //������껮��λ�úͱ༭��������õ��ܶȵȲ���ʵ����ֲ�� �����ϱ��
            }
            DrawBrush(raycastHit);
        }
        /// <summary>
        /// ���Ʊ�ˢ
        /// </summary>
        private static void DrawBrush(RaycastHit hit)
        {
            if (ArtBrushToolEW.BrushEnable)
            {
                //���ñ༭ģʽΪ��,����ˢ��ˢ��ʱ����޷�ʹ���ƶ���ת��
                Tools.current = Tool.None;
                //����Ĭ�ϵ�ѡ��,�����Ͳ���ѡ������
                HandleUtility.AddDefaultControl(GUIUtility.GetControlID(FocusType.Passive));

                //���Ʊ�ˢ��ʽ
                Handles.color = Color.white;
                Handles.DrawSolidDisc(hit.point, hit.normal, 1);
                Handles.color = Color.black;
                Handles.DrawWireDisc(hit.point, hit.normal, 2);
                Handles.DrawWireDisc(hit.point, hit.normal, 3);
                Debug.Log("�ڻ����ڻ���");
            }

        }
    }
}
#endif
